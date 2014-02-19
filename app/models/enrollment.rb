class Enrollment < ActiveRecord::Base
  belongs_to :conference
  belongs_to :user
  has_many :bids
  has_many :assignments
  
  searchable %w{users.first_name users.last_name users.university comment}
  
  # only one enrollment per user per conference
  validates_uniqueness_of :user_id, :scope => :conference_id
  
  # enroll a user in the given conference
  def self.enroll_user_in_conference(user, conference, status = nil, attributes = {})
    cond = {:conference_id => conference.id, :user_id => user.id}
    
    status ||= conference.lottery_run? ? Status::WAITLISTED : Status::ENROLLED
    attributes[:status] ||= status
    
    # determine lottery number
    if conference.lottery_run?
      attributes[:lottery] ||= connection.select_value('select max(lottery) from enrollments where conference_id=%i' % conference.id).to_i + 1
    end
    
    # update enrollment
    if enroll = find(:first, :conditions => cond)
      attributes.each { |k,v| enroll.send '%s=' % k, v }
      enroll.save!
    
    # ...or create a new one
    else
      enroll = create cond.merge(attributes)
    end
  end
  
  # retrieve bids for several tasks or create empty bid objects
  def bids_for_tasks(tasks)
    tasks.collect do |task|
      bid = task.bid_by_enrollment(self)
      bid ||= Bid.new :enrollment_id => id, :task_id => task.id
    end
  end
  
  # returns all assigned tasks (but includes assignment-information!)
  # ordered by conference day
  def assignments_with_tasks
    Assignment.find :all, :include => :task, :conditions => {:enrollment_id => id}, :order => 'tasks.day, tasks.start_time, tasks.end_time, tasks.name'
  end  
  
  # returns all bids with task
  # ordered by conference day
  def bids_with_tasks
    Bid.find :all, :include => :task, :conditions => {:enrollment_id => id}, :order => 'tasks.day, tasks.start_time, tasks.end_time, tasks.name'
  end  
  
  # return all bids (of specified preference level) for one day
  def bids_for_day(conference_day, preference = nil)
    trace 'is this function still in use?'
    cond = {}
    # for this user/enrollment
    cond[:enrollment_id] = id
    # for specified preference
    cond[:preference] = preference if preference
    # for specified day
    cond['tasks.day'] = conference_day
    # execute query
    Bid.find :all, :include => :task, :conditions => cond
  end
  
  # count all bids of the user
  def bids_count
    Bid.count :enrollment_id => id
  end
  
  # status name
  def status_name
    Status::name status
  end
  
  # returns bid-object of this task if any
  def bid
    bids.first if bids
  end
  
  # returns the assignment object, if it exists
  def assignment
    assignments.first if assignments
  end
  
  # Drop the enrollment
  def drop!
    self.status = Status::DROPPED
    self.lottery = nil
    save!
  end
  
  # is the sv enrolled?
  def enrolled?
    status != Status::DROPPED
  end
  
  # is the sv waitlisted?
  def waitlisted?
    status == Status::WAITLISTED
  end
  
  # is the sv registered?
  def registered?
    status == Status::REGISTERED
  end
  
  # is the sv dropped?
  def dropped?
    status == Status::DROPPED
  end
  
  # how many hours are assigned
  def hours_assigned
    @hours_assigned ||= Task::Hours.in Assignment.sum('hours', :conditions => {:enrollment_id => id, :status => [Assignment::ASSIGNED, Assignment::CHECKED_IN]}) || 0
  end
  
  # calculate hours of tasks I've bidden for (for one day)
  def hours_bid_for_day(day)
    query = "SELECT sum(hours) AS sum_hours FROM `Tasks` RIGHT JOIN `Bids` ON bids.task_id = tasks.id WHERE " + 
            "day = %i AND status = %i AND enrollment_id = %i" % [day.id, Bid::OPEN, self.id]
    Task::Hours.in Task.find_by_sql(query)[0].sum_hours
  end
  
  
  # how many hours are done
  def hours_done
    @hours_done ||= Task::Hours.in Assignment.sum('hours', :conditions => {:enrollment_id => id, :status => Assignment::DONE}) || 0
  end
  
  # how many hours total
  def hours_total
    Task::Hours.in(hours_assigned.to_f + hours_done.to_f)
  end
  
  # waitlist position
  def waitlist_position(waitlist)
    1 + waitlist.index(self) if waitlist.include? self
  end
  
  # score for lottery
  def lottery_score
    return 1 unless self.conference.lottery_config
    return @score if @score
    @score = self.user.degree if (self.conference.lottery_config.degree == 1)
    @score ||= 1
    @score += adjust_score :local_experience
    @score += adjust_score :past_conferences_this
    @score += adjust_score :past_sv_this
    @score += adjust_score :visa
    @score = 0 if @score < 0
    @score
  end
  
  protected
  
  # adjust the score according to the enrollment attributes and the conference settings for a key
  def adjust_score(key)
    score_adjust = self.conference.lottery_config.send(key)
    score_adjust = -score_adjust unless self.send(key)
    
    # required settings
    # -> required not fulfilled -> -1000 score
    # -> required fulfilled -> 0 score
    score_adjust = -1000 if score_adjust < -3
    score_adjust = 0 if score_adjust > 3

    # do not give negative score
    score_adjust = 0 if score_adjust != -1000 and score_adjust < 0
    
    score_adjust
  end
  
end
