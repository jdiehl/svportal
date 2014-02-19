class Ticket < ActiveRecord::Base
  before_save :create_ticket_code
  
  validates_uniqueness_of :user_id
  
  # create or update ticket
  def self.generate(user)
    ticket = find_by_user_id user.id
    ticket ||= new :user_id => user.id
    ticket.save!
    ticket
  end

  # checks if ticket with specified code exists (mustn't be older than 1 hour)
  def self.authenticate(code)
    find_by_code code#, :conditions => 'timestamp <= %i' % Time.now.ago(1.hour)
  end
  
  protected
  
  # create a new random ticket code
  def create_ticket_code
    require 'digest/sha1'
    self.code = Digest::SHA1.hexdigest(object_id.to_s + rand.to_s)
  end
end
