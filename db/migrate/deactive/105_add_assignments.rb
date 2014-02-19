class AddAssignments < ActiveRecord::Migration
  
  # assign given user to random task
  def self.create_assignment_for enroll
    # choose random task
    size = Task.count :all
    task = Task.find :first, :offset => rand(size)
    Assignment.assign_user_for_task(enroll, task)
  end
  
  def self.up
    # create assignment for max (test dummy)
    max = User.find :first
    enrolled_max = Enrollment.find_by_user_id max.id
    create_assignment_for enrolled_max
    
    # create assignments for some other users
    # TODO: ...
  end

  def self.down
    truncate :assignments
  end
end
