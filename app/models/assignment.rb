class Assignment < ActiveRecord::Base
  belongs_to :enrollment
  belongs_to :task
  
  # set hours from task if nil
  before_save :set_hours
  
  wrap :hours, Task::Hours

  # SV can only be assigned to a task once
  validates_uniqueness_of :enrollment_id, :scope => :task_id
  
  ASSIGNED = 1
  CHECKED_IN = 2
  DONE = 3

  # Status Names
  STATUS = {ASSIGNED => 'assigned', CHECKED_IN => 'checked-in', DONE => 'done'}
  
  # the admin/assignment interface cycles through these states
  CYCLE_STATUS = {ASSIGNED => CHECKED_IN, CHECKED_IN => DONE, DONE => ASSIGNED}
  
  # return the available status codes for assignments  
  def self.status_values
    STATUS.keys
  end
    
  # return the name for a status code
  def self.status_name(status)
    STATUS[status.to_i] or raise 'unknown status %s' % status.to_s
  end
  
  # on destroy -> mark bid as full (has to have a reason he got dropped)
  def destroy
    super
    bid.full! if bid
  end
  
  # accessor for a corresponding bid
  def bid
    Bid.find :first, :conditions => { :enrollment_id => enrollment_id, :task_id => task_id }
  end
  
  # accessor for user
  def user
    enrollment.user
  end
  
  # return the current status
  def status_name
    self.class.status_name(status)
  end
  
  # cycle the status
  def cycle_status
    self.status = Assignment::CYCLE_STATUS[status]
    save!
  end
  
  # are the hours different from the task hours?
  def hours_changed?
    hours != task.hours
  end
  
  # make empty comments nil
  def comment=(v)
    return super(nil) if v and v.empty?
    super v
  end
  
  # set hours from task if not set
  def set_hours
    self.hours = task.hours unless self.hours
  end

  # is the assignment conflicting?
  def check_for_conflict
    @conflict_count ||= Assignment.count :include => :task,
      :conditions => 'enrollment_id=%i and day=%i and ' % [enrollment.id, task.day] + 
        "start_time<'%s' and end_time>'%s' and assignments.id!=%i" % 
          [task.end_time, task.start_time, id]
    @conflict_count > 0
  end
    
end
