class ConferenceDay < I10::Report
  attr_accessor :conference
  attr_accessor :id
  attr_accessor :date
  
  def self.day_from_date(conference, date)
    conference.days.each do |day|
      return day if day.date == date
    end
    raise 'date %s not in conference' % date
  end
    
  # constructor
  def initialize(conference, id, date = nil)
    self.conference = conference
    self.id = id
    self.date = date if date
  end
  
  # date accessor
  def date
    return @date if @date
    return @date = nil if id == 0
    @date = conference.start_date + (id-1).days
  end
  
  # string representation
  def to_s
    return 'preliminiary' unless date
    format('%a') + ' %i/%i' % [date.month, date.day]
  end
  
  # create a human readable date
  def format(format = '%a %m/%d')
    date ? date.strftime(format) : 'preliminary'
  end
  
  # day comparison
  def ==(day)
    day and day.id == id
  end

  # count tasks for the conference day
  def tasks_count
    @tasks_count ||= Task.count :conditions => {:conference_id => conference.id, :day => id}
  end
  
  def tasks(options = {})
    options[:conditions] = [options[:conditions]].compact
    options[:conditions] << 'conference_id=%i' % conference.id
    options[:conditions] << 'day=%i' % id
    options[:conditions] = options[:conditions].join ' and '
    
    Task.find :all, options
  end
  
  # find all tasks for the conference day
  def tasks_with_assignments(options = {})
    options[:conditions] = [options[:conditions]].compact
    options[:conditions] << 't.conference_id=%i' % conference.id
    options[:conditions] << 't.day=%i' % id
    quoted_string = options[:search]
    
    cond = []
    ['t.name', 't.description', 'u.last_name', 'u.first_name'].each do |k|
      cond << "%s like '%%%s%%'" % [k, quoted_string]
    end

    query = 'SELECT t.* FROM tasks t left join assignments a on t.id = a.task_id left join enrollments e on e.id = a.enrollment_id left join users u on u.id = e.user_id WHERE '
    query += options[:conditions].join ' and '
    query += ' AND (%s)' % cond.join(' or ')
    query += ' GROUP BY t.id'
    query += ' ORDER BY %s' % options[:order]

    Task.find_by_sql query 
  end

  # find all tasks for the conference day
  def tasks_with_bids_and_assignments(enroll, options = {})
    query = 'SELECT t.*, a.status assignment_status, b.status bid_status, b.preference bid_preference FROM tasks t '
    query +='LEFT JOIN assignments a ON a.task_id = t.id AND a.enrollment_id=%i ' % enroll.id
    query +='LEFT JOIN bids b ON b.task_id = t.id AND b.enrollment_id=%i ' % enroll.id
    query +='WHERE t.conference_id=%i AND t.day=%i AND t.invisible=0 ' % [conference.id, id]
    query +='ORDER BY start_time, end_time, name'
    Task.find_by_sql query
  end
  
  # get all task hours for the day
  def task_hours
    @task_hours ||= Hours.in ActiveRecord::Base.connection.select_value(
      'select sum(hours*slots) from tasks where conference_id=%i and day=%i' % [conference.id, id]).to_f
  end
  
  # get assigned hours
  def assignment_hours
    return @assignment_hours if @assignment_hours
    @assignment_hours = {}
    query = 'select status, sum(hours) hours from assignments ' +
      'where task_id in (select id from tasks where conference_id=%i and day=%i) ' % [conference.id, id] +
      'group by status'
    I10::Report.find_by_sql(query).each { |o| @assignment_hours[o.status.to_i] = o.hours }
    @assignment_hours
  end
  
  # is bidding allowed on this day?
  def allow_bidding?
    @allow_bidding ||= !conference.bid_day or conference.bid_day >= id
  end
  
  # assigned hours
  def hours_assigned
    return nil if assignment_hours[Assignment::ASSIGNED].nil? and assignment_hours[Assignment::CHECKED_IN].nil?
    Hours.in assignment_hours[Assignment::ASSIGNED].to_f + assignment_hours[Assignment::CHECKED_IN].to_f
  end
  
  # done hours
  def hours_done
    Hours.in assignment_hours[Assignment::DONE]
  end
  
  # total hours
  def hours_total
    hours = 0
    assignment_hours.each { |k,v| hours += v.to_f }
    Hours.in hours == 0 ? nil : hours
  end
  
end