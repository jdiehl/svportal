class AdminUser < ActiveRecord::Base
  
  MODERATOR = 0
  ADMINISTRATOR = 1
  SUPER_ADMINISTRATOR = 2
  
  STATUS = {
    MODERATOR => 'Moderator',
    ADMINISTRATOR => 'Administrator',
    SUPER_ADMINISTRATOR => 'Super Administrator'
  }

  attr_accessor :password
  
  # authenticate
  def self.authenticate(login)
    user = find_by_login(login[:login]) or raise 'User not found'
    user.authenticate login[:password] or raise 'Invalid Password'
    user
  end
  
  # status string representation
  def status_name
    STATUS[status]
  end
  
  # authenticate by password
  def authenticate(password)
    password_hash == encrypt(password)
  end
  
  # is moderator
  def moderator?
    status >= MODERATOR
  end
  
  # is admin
  def admin?
    status >= ADMINISTRATOR
  end
  
  # is super_admin
  def super_admin?
    status >= SUPER_ADMINISTRATOR
  end
  
  protected

  # Encrypt anything
  def self.encrypt(*args)
    require 'digest/sha1'
    Digest::SHA1.hexdigest args.join
  end
  
  # Generate a random salt
  def self.salt(*args)
    args << Time.now.to_s
    args << rand(1000000).to_s
    encrypt args.join
  end
  
  # encrypt a string
  def encrypt(string)
    self.class.encrypt string, salt
  end
  
  # before save
  # encrypt password
  def before_save
    if password
      self.salt = self.class.salt
      self.password_hash = encrypt password
    end
  end
  
end
