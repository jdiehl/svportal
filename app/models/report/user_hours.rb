class Report::UserHours < I10::Report
  ASSIGNMENT_ASSIGNED = [Assignment::ASSIGNED, Assignment::CHECKED_IN].join ','
  ASSIGNMENT_DONE = Assignment::DONE
  ENROLLMENT_REGISTERED = [Status::REGISTERED, Status::ONSITE].join ','

  # get user hours report
  def self.find(conference, search = nil, order = nil)
    order = 'last_name, first_name' if order == 'name'
    order = 'last_name DESC, first_name DESC' if order == 'name desc'
    query = 'select e.*, u.first_name, u.last_name, ' +
      '(select count(*) from bids b where b.enrollment_id = e.id) as bids_count, ' % ASSIGNMENT_ASSIGNED +
      '(select sum(hours) from assignments a where a.enrollment_id = e.id and a.status in (%s)) as hours_assigned, ' % ASSIGNMENT_ASSIGNED +
      '(select sum(hours) from assignments a where a.enrollment_id = e.id and a.status=%i) as hours_done, ' % ASSIGNMENT_DONE +
      '(select sum(hours) from assignments a where a.enrollment_id = e.id) as hours_total ' +
      'from enrollments e, users u ' +
      'where e.user_id = u.id and e.conference_id = %i and e.status in (%s) ' % [conference.id, ENROLLMENT_REGISTERED] +
      (search ? 'and %s ' % Enrollment.search_conditions(search) : '') +
      'order by %s' % order
    find_by_sql query
  end
  
  # how many hours are assigned
  def hours_assigned
    Task::Hours.in super
  end
  
  # how many hours are done
  def hours_done
    Task::Hours.in super
  end
  
  # how many hours total
  def hours_total
    Task::Hours.in super
  end
  
end
