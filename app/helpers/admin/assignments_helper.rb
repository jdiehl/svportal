module Admin::AssignmentsHelper

  # select a day
  def link_to_day(title, day, options = {})
    link_to_remote title, :update => 'tasks_list', :url => {:action => 'list', :day => day}, :method => 'get'
  end
  
  # show the users list for a task
  def link_to_users(title, task, options = {})
	  link_to_function title, "new ShowAssignmentUsers(this,%i)" % task.id, options
  end
  
  # assign a user to a task
  def link_to_assign(title, task, enrollment)
    options = { :enrollment_id => enrollment.id, :task_id => task.id }
		link_to_function title, 'new UpdateAssignment(this,%s)' % options.to_json
  end
  
  # unassign a user from a task
  def link_to_unassign(title, task, enrollment)
    options = { :enrollment_id => enrollment.id, :task_id => task.id }
		link_to_function title, 'new DeleteAssignment(this,%s)' % options.to_json
  end
  
  # change hours
  def link_to_change_hours(assignment, options = {})
    title = pluralize assignment.hours, 'hour'
		link_to_function title, "new ShowAssignmentHours(this,%i)" % assignment.id, options
  end
  
  # toggle status
  def link_to_cycle_status(assignment)
    link_to_function assignment.status_name, "new CycleAssignmentStatus(this,%i)" % assignment.id
  end
  
  def get_total_hours_from_enroll(hours, enroll)
    hours[enroll.id]
  end
    
end
