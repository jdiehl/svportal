class Bid < ActiveRecord::Base
  belongs_to :tasktype
  belongs_to :enrollment
  
  # preference
  HIGH, MEDIUM, LOW = 1, 2, 3
  PREFERENCE = {HIGH => 'high', MEDIUM => 'medium', LOW => 'low'}
  PREFERENCE_LIMIT_MIN = {HIGH => 1, MEDIUM => 0, LOW => 0}
  PREFERENCE_LIMIT_MAX = {HIGH => 2, MEDIUM => 2, LOW => false}
  
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
  def self.bid_on_remaining_tasks_user(conference, enroll)
    query = 'INSERT INTO `bids` (`enrollment_id`, `status`, `task_id`, `preference`) '+
      'SELECT %i, %i, tasks.id, %i FROM tasks ' % [enroll.id, OPEN, LOW] +
      'WHERE conference_id=%i ' % [conference.id] +
      'AND id not in (select task_id from bids where enrollment_id=%i) ' % [enroll.id] +
      'AND id not in (select task_id from assignments where enrollment_id=%i)' % [enroll.id]
    connection.insert query
  end
  
  # delete all bids of one user
  def self.remove_bids_for_user(conference, enroll)
    # raise 'bidding disabled' unless day.allow_bidding?
    Bid.delete_all 'enrollment_id=%i and tasktype_id in (select id from tasktypes where conference_id=%i)' % [enroll.id, conference.id]
  end
  
  def self.validate_preference_limit(bids)
    @h = Hash.new
    bids.split('|').each do |ttid_bid|
      @ttid = ttid_bid.split(',')[0].to_i
      @pref = ttid_bid.split(',')[1].to_i
      @tasktype = Tasktype.find :first, :conditions => {:id => @ttid}
      if @tasktype then
        if not @h.has_key?(@tasktype.category_id) then
          @h[@tasktype.category_id] = Array.new
        end
        @h[@tasktype.category_id] << @pref
      end
    end

    @result = true
    @h.keys.each do |catid|
      @highs = @h[catid].count(HIGH).to_i
      @mediums = @h[catid].count(MEDIUM).to_i
      @lows = @h[catid].count(LOW).to_i

      if not (@highs >= 1 and @highs <= 2 and @mediums <= 2) then
        @result = false
      end
    end

    @result
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
  def assign(day)
    result = false
    
    # check if task is full
    if tasktype.full?
      full! unless full?
      return false
    end
    
    # assign the bid
    transaction do
      result = tasktype.assign_user enrollment, day
      
      if result then
        #self.status = ASSIGNED
        save!
      end
    end
    result
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
  
end
