require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :enrollment
  belongs_to :country, :foreign_key => 'home_country_id'
  belongs_to :tshirt_size
  
  GENDERS = {'f' => 'female', 'm' => 'male'}
  
  DEGREE = {
    1 => 'Bachelor\'s',
    2 => 'Masters',
    3 => 'PhD'
  }
  searchable %w{first_name last_name email university}
  
  # virtual attribute for clear-text password
  attr_accessor :password
  before_save :encrypt_password
  before_save :clear_password_old
  
  # virtual password for verifying an old password
  attr_accessor :password_old
  
  # some constraints
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :home_country_id
  validates_presence_of :university
  validates_presence_of :tshirt_size_id
  
  # email is required for users login
  validates_uniqueness_of :email, :if => 'email'
  validates_format_of :email, :with => /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,6}$/i, :if => 'email'
  validates_format_of :gender, :with => /^[fm]$/

#  validates_presence_of :password
  validates_length_of :password, :minimum => 6, :if => :password
  validates_confirmation_of :password, :if => :password
  
  # authenticate by email and password
  def self.authenticate(email, pwd)
    return nil unless email
    user = self.find_by_email(email)
    return nil unless user
    user = nil unless user.authenticate(pwd)
    user
  end
  
  # authenticate by token
  def self.authenticate_by_token(token)
    find_by_remember_token(token)
  end
  
  # authenticate by recovery token
  def self.authenticate_with_recovery_token(token)
    find_by_recovery_token(token)
  end
  
  def password
    @password == '' ? nil : @password
  end
  
  # generate a new token
  def create_token
    self.token = encrypt(salt, Time.now)
  end
  
  # retrieve the enrollment status
  def status(conference)
    enroll = Enrollment.find :first,
      :conditions => {:user_id => id, :conference_id => conference.id}
    enroll.status if enroll
  end
  
  # retrieve the enrollment status as a string
  def status_string(conference)
    enroll = Enrollment.find :first,
      :conditions => {:user_id => id, :conference_id => conference.id}
    enroll.status_name if enroll
  end
  
  # enroll this user in a conference
  def enroll_in_conference(conference, attributes = {})
    Enrollment.enroll_user_in_conference(self, conference, nil, attributes)
  end
  
  # get the enrollment object for a conference
  def enrollment_for_conference(conference)
    Enrollment.find :first, :conditions => {:user_id => id, :conference_id => conference.id}
  end
  
  # string representation
  def to_s
    name
  end
  
  # full name
  def name
    '%s, %s' % [last_name, first_name]
  end
  
  # authenticate by password
  def authenticate(pwd)
    password_hash == self.class.encrypt(pwd, salt)
  end
  
  # generate ticket to reset password and send it by email
  def password_request(conference, url)
    create_recovery_token
    save!
    url[:token] = recovery_token
    Mailer.deliver_password_request conference, self, url
  end  
  
  ### protected methods ###
  protected
  
  # SHA1 encryption with salt
  def self.encrypt(*args)
    Digest::SHA1.hexdigest(args.join(''))
  end
  
  # generate salt and encrypt the clear-text password (if set)
  def encrypt_password
    return if password.nil?
    self.recovery_token = nil
    create_salt
    self.password_hash = self.class.encrypt(password, salt)
  end
  
  # create a pseudo-random salt
  def create_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  # create a pseudo-random recovery token
  def create_recovery_token
    self.recovery_token = self.class.encrypt(object_id.to_s + rand.to_s)
  end

  # create a pseudo-random remember token
  def create_remember_token
    self.remember_token = self.class.encrypt(object_id.to_s + rand.to_s)
  end

  # Custom Validation
  def validate
    errors.add_to_base 'Wrong current password' unless !password_old or authenticate(password_old)
  end
  
  # clear the old password
  def clear_password_old
    self.password_old = nil
  end
end
