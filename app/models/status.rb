# this class is for the students' (registration) status only
# the conferences' status is realized within the conference model
#
class Status
  attr_accessor :id, :conference
  
  DROPPED = 0
  ENROLLED = 1
  WAITLISTED = 2
  ACCEPTED = 3
  REGISTERED = 4
  ONSITE = 5
  
  STATUS = {
    DROPPED => 'dropped',
    ENROLLED => 'enrolled',
    WAITLISTED => 'on waitlist',
    ACCEPTED => 'accepted',
    REGISTERED => 'registered'
  }
  
  STATUS_CODES = {
    DROPPED => 'DRP',
    ENROLLED => 'ENR',
    WAITLISTED => 'WTL',
    ACCEPTED => 'ACC',
    REGISTERED => 'REG'
  }
  
  # return all status items in order
  def self.find_by_conference(id, conference)
    return new(id, conference) unless id == :all
    STATUS.keys.collect { |k| new k, conference }
  end
  
  def self.name(status)
    STATUS[status.to_i] or 'invalid status: %s' % status.to_s
  end
  
  def self.code(status)
    STATUS_CODES[status.to_i] or 'invalid status: %s' % status.to_s
  end
  
  def self.each
    [DROPPED, ENROLLED, WAITLISTED, ACCEPTED, REGISTERED].each { |k| yield k }
  end
  
  # constructor (id required)
  def initialize(id, conference = nil)
    id = id.to_i
#    raise 'unknown status id: %i' % id unless STATUS.has_key?(id)
    self.id = id
    self.conference = conference
  end
  
  # status code
  def code
    self.class.name id
  end
  
  # status name
  def name
    self.class.name id
  end
  
  # string representation
  def to_s
    name
  end
  
  # integer representation
  def to_i
    id
  end
  
  # has many: enrollments
  def enrollments
    Enrollment.find :all, :conditions => {:conference_id => conference.id, :status => id}
  end
  
  # count enrollments
  def count_enrollments
    Enrollment.count :all, :conditions => {:conference_id => conference.id, :status => id}
  end
  
  # comparison
  def ==(status)
    return(status.id == id) if status.is_a? Status
    status == id
  end
  
end
