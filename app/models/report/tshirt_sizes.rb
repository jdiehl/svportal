class Report::TshirtSizes < I10::Report

  # get tshirt sizes overview
  def self.find(conference)
    query = 'select t.name, count(*) amount from enrollments e, users u, tshirt_sizes t ' +
      'where e.user_id = u.id and u.tshirt_size_id = t.id ' +
      'and e.conference_id = %i and e.status >= %i ' % [conference.id, Status::ACCEPTED] +
      'group by t.name ' +
      'order by u.tshirt_size_id'
    data = find_by_sql query

    query = 'select "unknown" name, count(*) amount from enrollments e, users u ' +
      'where e.user_id = u.id and u.tshirt_size_id is null ' +
      'and e.conference_id = %i and e.status >= %i ' % [conference.id, Status::ACCEPTED]
    data += find_by_sql query
    data
  end
  
end
