class Task < ActiveRecord::Base
  belongs_to :conference
  has_many :assignments
  has_many :bids

  searchable %w{name description}
  wrap :start_time, 'ShortTime'
  wrap :end_time, 'ShortTime'
  wrap :hours, 'Hours'
  
  validates_presence_of :name
  validates_presence_of :start_time
  validates_presence_of :end_time
  validates_numericality_of :hours
  validates_numericality_of :slots  
  
  PRIORITY = {0 => 'high', 1 => 'normal', 2 => 'low'}
  
  # allow setting of hours_m in new / create
  def initialize(attributes = nil)
    if attributes and !attributes[:hours]
      h = attributes.delete(:hours_h).to_i if attributes[:hours_h]
      m = attributes.delete(:hours_m).to_i if attributes[:hours_m]
      attributes[:hours] = h ? h : 0
      attributes[:hours] += m/60.0 if m
    end
    super(attributes)
  end
  
  # available priorities
  def self.priority_values
    PRIORITY.keys
  end
  
  # name a priority code
  def self.priority_name(priority)
    PRIORITY[priority]
  end
  
  # assign a user to a task
  def assign_user(enrollment)
    Assignment.create :enrollment_id => enrollment.id, :task_id => id
  end
  
  # return assignments (existing or new) for all slots of this task
  def assignments_for_slots
    items = assignments.to_a
    items << false while items.length < slots
    items
  end
  
  # we need days as numbers
  def day=(v)
    super v.to_i
  end
  
  # name of the priority
  def priority_name
    self.class.priority_name priority
  end
  
  def bids_by_preference
    @bids ||= Bid.find :all, :conditions => { :task_id => id }, :order => 'preference'
  end

  # returns bid-object of this task if any
  def bid
    bids.first if bids
  end
  
  # returns the assignment object, if it exists
  def assignment
    assignments.first if assignments
  end
  
  # checks whether all slots are reserved
  def full?
    #return @full if @full
    return(@full = true) if assignments.count >= slots
    false
  end
  
  # checks if bids are assigned to this task
  def has_bids?
    bids.count > 0
  end   
  
  # find users with bids and assignments
  def users_with_bids_and_assignments(search)
    status_registered = [Status::REGISTERED, Status::ONSITE].join ','
    query = 'select e.id, e.lottery, u.first_name, u.last_name, a.status as assignment_status, b.status as bid_status, b.preference as bid_preference ' +
      'from enrollments e ' +
      'left join assignments a on e.id = a.enrollment_id and a.task_id = %i ' % id +
      'left join bids b on e.id = b.enrollment_id and b.task_id = %i ' % id +
      'join users u on u.id = e.user_id ' +
      'where e.conference_id=%i and e.status in (%s) ' % [conference_id, status_registered] + 
      (search ? 'and %s ' % User.search_conditions(search) : '') +
      'order by ISNULL(b.preference), b.preference, u.last_name, u.first_name'
    Enrollment.find_by_sql query
  end

  # extended 'users_with_bids_and_assignments' to query for users assigned hours
  def users_with_bids_and_assignments_and_hour_report(search)
    status_registered = [Status::REGISTERED, Status::ONSITE].join ','
    query = 'select e.id, e.lottery, u.first_name, u.last_name, a.status as assignment_status, b.preference as bid_preference, '
    query += '(select sum(hours) from assignments where enrollment_id = e.id) as hours_total '
    query += 'FROM enrollments e '
    query += 'LEFT JOIN assignments a ON e.id = a.enrollment_id AND a.task_id = %i ' % id
    query += 'LEFT JOIN bids b ON e.id = b.enrollment_id AND b.task_id = %i ' % id
    query += 'JOIN users u ON u.id = e.user_id '
    query += 'WHERE e.conference_id=%i AND e.status IN (%s) ' % [conference_id, status_registered]
    query += (search ? 'AND %s ' % User.search_conditions(search) : '')
    query += 'ORDER BY ISNULL(b.preference), b.preference, u.last_name, u.first_name'
    Enrollment.find_by_sql query
  end
  
  # can the task be deleted?
  def can_delete?
    assignments.empty?
  end
  
# end_time accessors
  def end_time_h
    self.end_time.hours
  end
  def end_time_h=(v)
    h = self.end_time
    h.hours = v
    self.end_time = h
  end
  def end_time_m
    end_time.minutes
  end
  def end_time_m=(v)
    h = self.end_time
    h.minutes = v
    self.end_time = h
  end
  
  # start_time accessors
  def start_time_h
    self.start_time.hours
  end
  def start_time_h=(v)
    h = self.start_time
    h.hours = v
    self.start_time = h
  end
  def start_time_m
    start_time.minutes
  end
  def start_time_m=(v)
    h = self.start_time
    h.minutes = v
    self.start_time = h
  end
  
  # hours accessors
  def hours_h
    hours.hours if hours
  end
  def hours_h=(v)
    h = self.hours || ShortTime.new
    h.hours = v
    self.hours = h
  end
  def hours_m
    hours.minutes if hours
  end
  def hours_m=(v)
    h = self.hours || ShortTime.new
    h.minutes = v
    self.hours = h
  end
  
  protected
  
  # custom validations
  def validate
    #TODO: test time format for start_time / end_time
    errors.add_to_base 'end time must be after start time' if start_time and end_time and end_time <= start_time
  end
  
end
