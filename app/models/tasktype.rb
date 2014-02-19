class Tasktype < ActiveRecord::Base
  belongs_to :category
  has_many :tasks
  
  validates_presence_of :name
  validates_presence_of :description
  
  # checks whether all slots are reserved
  def full?
    tasks = Task.find :all, :conditions => { :tasktype_id => self.id }
    s = false
    tasks.each do |t|
      s ||= t.full?
    end
    s
  end
  
  def slots
    tasks = Task.find :all, :conditions => { :tasktype_id => self.id }
    s = 0
    tasks.each do |t|
      s += t.slots
    end
    s
  end
  
  # returns bid-object of this task if any
  def bid
    bids.first if bids
  end
  
  def bids_by_preference
    @bids ||= Bid.find :all, :conditions => { :tasktype_id => id }, :order => 'preference'
  end

  # assign a user to a task from this tasktype depending on user's availability
  def assign_user(enrollment, day)
    result = false
    
    cond = 'availabilities.day = "%s" and availabilities.enrollment_id = %i' % [day.date, enrollment.id]
    n = Timeslot.count(:conditions => cond, :include => 'availabilities')
    
    if n == 0 then
      tasks = Task.find :all, :conditions => { :tasktype_id => self.id, :day => day.id }
    else
      query = '
    select t.*
    from tasks t
    where 0 = (select count(*)
               from timeslots ts
                    join availabilities a on (ts.id = a.timeslot_id)
               where a.day = "%s" 
                     and a.enrollment_id = %i
                     and t.end_time > ts.start_time
                     and ts.end_time > t.start_time)
          and t.day = %i
          and t.tasktype_id = %i
    ' % [day.date, enrollment.id, day.id, self.id]
      tasks = Task.find_by_sql query
    end
        
    if tasks != nil then
      task = tasks.first
      if task != nil then
        result = true
        task.assign_user enrollment
        Assignment.create :enrollment_id => enrollment.id, :task_id => task.id
      end
    end
    result
  end
  
end