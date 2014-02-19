class Bid < ActiveRecord::Base
  belongs_to :task
  belongs_to :enrollment
  
  # preference
  HIGH, MEDIUM, LOW = 1, 2, 3
  PREFERENCE = {HIGH => 'high', MEDIUM => 'medium', LOW => 'low'}
  PREFERENCE_LIMIT = {HIGH => 3, MEDIUM => 10, LOW => false}
  
  OPEN, ASSIGNED, FULL, CONFLICT = 1, 2, 3, 4
  STATUS = {OPEN => 'open', ASSIGNED => 'assigned', FULL => 'full', CONFLICT => 'conflict'}
  
  # translate preference code to name
  def self.preference_name(preference)
    PREFERENCE[preference.to_i]
  end
  
  # translate status code to name
  def self.status_name(status)
    STATUS[status.to_i]
  end
  
  # bid for all free tasks with lowest priority
  def self.bid_on_remaining_tasks_for_day_and_user(day, enroll)
    raise 'bidding disabled' unless day.allow_bidding?
    query = 'INSERT INTO `bids` (`enrollment_id`, `status`, `task_id`, `preference`) '+
      'SELECT %i, %i, tasks.id, %i FROM tasks ' % [enroll.id, OPEN, LOW] +
      'WHERE conference_id=%i AND day=%i ' % [day.conference.id, day.id] +
      'AND id not in (select task_id from bids where enrollment_id=%i and day=%i) ' % [enroll.id, day.id] +
      'AND id not in (select task_id from assignments where enrollment_id=%i and day=%i)' % [enroll.id, day.id]
    connection.insert query
  end
  
  # delete all bids of one user for a specified day
  def self.remove_bids_for_day_and_user(day, enroll)
    raise 'bidding disabled' unless day.allow_bidding?
    Bid.delete_all 'enrollment_id=%i and task_id in (select id from tasks where day=%i and conference_id=%i)' % [enroll.id, day.id, day.conference.id]
  end
  
  def to_s
    'Bid (%s:%s) by %s on %s' % [status_name, preference_name, user.last_name, task.name]
  end
  
  # status name
  def status_name
    self.class.status_name status
  end
  
  # name for the preference
  def preference_name
    self.class.preference_name preference
  end
  
  # user accessor
  def user
    enrollment.user
  end
  
  # assign the bid
  def assign!
    raise 'bid already assigned' if status != OPEN
    
    # check if task is full
    if task.full?
      full! unless full?
      return false
    end
    
    # chick if task is in conflict
    if check_for_conflict
      conflict! unless conflict?
      return false
    end
    
    # assign the bid
    transaction do
      self.status = ASSIGNED
      save!
      task.assign_user enrollment
    end
    true
  end
  
  # unassign the bid
  def unassign!
    self.status = OPEN
    save!
  end
  
  # mark the bid as full
  def full!
    self.status = FULL
    save!
  end
  
  # make the bid as conflicting
  def conflict!
    self.status = CONFLICT
    save!
  end
  
  # are we still open?
  def open?
    status == OPEN
  end
  
  # are we full?
  def full?
    status == FULL
  end
  
  # are we conflicting?
  def conflict?
    status == CONFLICT
  end
  
  # is the bid conflicting?
  def check_for_conflict
    @conflict_count ||= Assignment.count :include => :task,
      :conditions => 'enrollment_id=%i and day=%i and ' % [enrollment.id, task.day] + 
        "start_time<'%s' and end_time>'%s'" % [task.end_time, task.start_time]
    @conflict_count > 0
  end
  
  protected
  
  def validate_preference_limit
    return true unless enrollment_id and preference
    return true unless limit = PREFERENCE_LIMIT[preference]
    cond = 'enrollment_id=%i and preference=%i and status=%i' % [enrollment_id, preference, OPEN]
    cond += ' and bids.id!=%i' % id if id
    cond += ' and tasks.day=%i' % task.day
    cond += ' and bids.status=%i' % OPEN
    Bid.count(:conditions => cond, :include => 'task') <= (limit - 1)
  end
  
  # custom validations
  def validate
    # bidding not allowed
    errors.add_to_base 'Bidding not allowed for this day' unless task.conference.day(task.day).allow_bidding?
    # maximum number of bids
    errors.add_to_base 'You cannot bid on more than %i tasks for one day with status %s' % 
      [PREFERENCE_LIMIT[preference], PREFERENCE[preference]] unless validate_preference_limit
    if open?
      # full or conflict
      errors.add_to_base 'Cannot bid on full task.' if task.full?
      # don't check for conflicts, if save->validate is called by method 'conflict!'
      errors.add_to_base 'Bid is in conflict' if check_for_conflict 
    end
  end
end
