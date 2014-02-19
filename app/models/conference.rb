class Conference < ActiveRecord::Base
  has_many :categories

  PLANNING = 0
  ENROLLMENT = 1
  REGISTRATION = 2
  BIDDING = 3
  RUNNING = 4
  OVER = 5
  ASSIGNING = 6
  
  STATUS = {
    PLANNING => 'Planning',
    ENROLLMENT => 'Enrollment',
    REGISTRATION => 'Registration',
    BIDDING => 'Bidding',
    RUNNING => 'Running',
    ASSIGNING => 'Assigning Tasks',
    OVER => 'Over'
  }
  
  STATUS_EXPLAINATION = {
    PLANNING => 'the conference is invisible to students (only open for administrative purposes)',
    ENROLLMENT => 'students can enroll in the conference',
    REGISTRATION => 'the lottery was run and we are waiting for student registrations',
    BIDDING => 'the tasks are prepared and can be bid for',
    RUNNING => 'the conference is running',
    ASSIGNING => 'bidding is temporarily disabled for manual task assignment',
    OVER => 'the conference is over'
  }
  
  # loads only those conferences, that ought to be visible for SVs
  def self.find_active
    find :all, :conditions => {:status => [ENROLLMENT, REGISTRATION, BIDDING, RUNNING, ASSIGNING]}
  end
  
  # return status options for select form
  def self.status_options
    STATUS.sort.collect { |k,v| [v,k] }
  end
  
  # string representation
  def to_s
    name
  end
  
  # return the active days of the conference
  def days
    return @days unless @days.nil?
    
    # validate dates
    return [] if start_date.nil? or end_date.nil? or start_date > end_date
#    raise 'start date not set' if start_date.nil?
#    raise 'end date not set'   if end_date.nil?
#    raise 'start date must be before end date' unless start_date <= end_date

    # create a ConferenceDay for each date in the conference
    i = 1
    date = start_date
    @days = [ConferenceDay.new(self, 0)]
    while date <= end_date
      @days << ConferenceDay.new(self, i, date)
      i += 1
      date += 1.day
    end

    @days
  end
  
  # return the categories of the conference
  def categories
    Category.find :all, :conditions => {:conference_id => self.id}
  end

  def tasktypes
    Tasktype.find :all, :conditions => {:conference_id => self.id}
  end

# return the nth day of the conference
  def day(id)
    days[id.to_i]
  rescue
    raise 'unknown day %s' % id.to_s
  end
  
  # return all registered users
  def registered_users
    Enrollment.find :all, :conditions => {:status => Status::REGISTERED}
  end
  
  # return enrollment status
  def enrollment_status(id = nil)
    return Status.find_by_conference(id, self) if id
    @status_list ||= Status.find_by_conference :all, self
  end
  
  # count all enrolled users
  def count_enrollments(status = :all)
    unless @count_enrollments
      @count_enrollments = { :all => 0 }
      query = 'select count(*) count, status from enrollments where conference_id=%i group by status' % id
      Enrollment.find_by_sql(query).each do |e|
        @count_enrollments[e.status] = e.count.to_i
        @count_enrollments[:all] += e.count.to_i
      end
    end
    @count_enrollments[status] || 0
  end
  
  # return conference status
  def status_name
    STATUS[status]
  end
  
  # decides, if SVs are allowed to enroll
  def open_enrollment?
    status == ENROLLMENT or status == REGISTRATION
  end
  
  # retrieve all enrolled students for waitlist
  def waitlist
    Enrollment.find :all, 
      :conditions => {:conference_id => id, :status => Status::WAITLISTED},
      :include => 'user', 
      :order => 'lottery'
  end

  # retrieve all accepted students
  def accepted
    Enrollment.find :all, 
      :conditions => {:conference_id => id, :status => [Status::ACCEPTED, Status::REGISTERED, Status::ONSITE]},
      :include => 'user', 
      :order => 'users.last_name,users.first_name'
  end
  
  # retrieve all registered and onsite students
  def registered
    Enrollment.find :all,
      :conditions => {:conference_id => id, :status => [Status::REGISTERED, Status::ONSITE]},
      :include => 'user',
      :order => 'last_name, first_name'
  end
  
  # retrive a draft for a certain event specified for this conference
  def draft_for_event(event)
    draft = Draft.find :first, :conditions => {:conference_id => id, :event => event}
    raise "no mail draft specified for conference '%s', event '%s'" % [self, Draft.event_name(event)] unless draft
    draft
  end
  
  # is the waitlist enabled?
  def waitlist_enabled?
    status == REGISTRATION or status == BIDDING 
  end
  
  # is the bidding system enabled?
  def bidding_enabled?
    status == BIDDING or status == RUNNING
  end
  
  # are manuel assignments done?
  def bidding_temp_disabled?
    status == ASSIGNING
  end
  
  # has the lottery run?
  def lottery_run?
    status > ENROLLMENT
  end
  # string representation

  def maintenance
    false
  end
end
