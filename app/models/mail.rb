class Mail < ActiveRecord::Base
  belongs_to :conference
  
  before_save :make_from, :make_to
  
  validates_presence_of :subject
  validates_presence_of :text
  
  # all status names that can be used for to
  def self.status_options
    names = Status::STATUS
    names[-1] = 'custom'
    names.sort.collect { |k,v| [v,k] }
  end
  
  # status name
  def status_name
    return 'custom' unless status
    Status.name status
  end
  
  # negative status (for sorting reasons) is converted to nil
  def status=(value)
    value = nil if value.to_i < 0
    write_attribute :status, value
  end
  
  # retrieve emails from to
  def emails
    list = to ? to.split(';') : []
    # add custom eails
    list += custom.split(';') if custom
    # add conference email for checking purposes
    list << conference.email
    list.compact
  end
  
  # get the from address from the conference
  def make_from
    self.from = conference.email
  end
  
  # filter input for emails
  def custom=(value)
    if value
      list = value.split(/[;:\s]+/).collect { |e| e.strip if e =~ /@/ }
      list.compact!
    end
    write_attribute :custom, list.join(';')
  end
  
  # get the to addresses from the status
  def make_to
    return '' unless status
    cond = { :conference_id => conference.id, :status => status }
    users = Enrollment.find :all, 
      :conditions => cond,
      :include => :user
    emails = users.collect { |e| e.user.email }
    
    self.to = emails.compact.join ';' 
  end
  
  # deliver the emails
  def deliver
    emails.each do |email|
      Mailer.deliver_mail email, from, subject, text
    end
  end
  
  # return the count of reciepients
  def count
    emails.count
  end
  
end
