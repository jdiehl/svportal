class Draft < ActiveRecord::Base
  belongs_to :conference
  
  validates_presence_of :subject
  validates_presence_of :text

  ENROLLED, WAITLISTED, ACCEPTED, REGISTERED, DROPPED = 1, 2, 3, 4, 6
  EVENT_NAMES = {
    nil => 'None',
    ENROLLED => 'Enrolled',
    WAITLISTED => 'Waitlisted',
    ACCEPTED => 'Accepted',
    REGISTERED => 'Registered',
    DROPPED => 'Dropped',
  }
  
  # find the draft for a status change event
  def self.find_by_status(status)
    find_by_event status
  end
  
  # returns description of event type
  def self.event_name(event)
    EVENT_NAMES[event]
  end
  
  # returns description of current event type
  def event_name
    self.class.event_name(event)
  end
  
  # markup the text with variables
  def markup_text(variables)
    parsed_text = text
    variables.each { |k,v| parsed_text.gsub! k, v }
    parsed_text
  end
  
  # custom validation
  def validate
    errors.add :event, 'has already been taken' if event and self.class.count(
      :conditions => 'conference_id=%i and event=%i and id!=%i' % [conference_id, event, id]) > 0
  end
end
