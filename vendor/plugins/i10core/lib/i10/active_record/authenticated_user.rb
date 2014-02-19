# Allows easy generation of authenticating models
# 
# == Model Definition
# 
# The most basic version of the authenticating model must define two columns:
# 
#   * (string:40) password_hash: stores the hashed password
#   * (string:40) salt: stores the random salt
# 
# This is already sufficient to allow basic authentication. To make use of the
# authentication by token (for remember me functionality), you need to define
# the following columns in addition:
# 
#   * (string:40) token: stores the random token
#   * timestamps: used for token authentication
# 
# To allow recovery tokens for password recovery, you need another column:
# 
#   * (string:40) recover_token: stores the random recovery token
# 
# == Authentication by Token
# 
# Authentication by token is used to authenticate via a remember-me-cookie.
# For security reasons, a new token should be generated every time it is used.
# 
#   if cookie[:token]
#     @user = authenticate_by_token cookies.token
#     cookies[:token] = { :value => @user.create_token!, :expires => 1.month.from_now }
#   end
# 
# == Using the Recovery Token
# 
# The recovery token is used to recover a lost password by email. It is
# generated for and embedded in the email that is sent to the user, and
# automatically deleted, when the user successfully changes the password.
# To implement password recovery, you only need to define the following
# methods in your controller. Note that this example assumes the use of
# I10::ActiveRecord::RestfulController.
# 
#   # send the email for the password request
#   def password_request
#     user = User.find :first, :conditions => params[:user]
#     mailer.deliver_password_recovery user, url_for(:action => reset_password, :token => user.create_recovery_token!)
#   end
#   
#   # show form to reset password
#   def reset_password
#     raise 'invalid token' unless @user = User.authenticate_by_recovery_token(params[:token])
#   end
#   
#   # reset the password
#   def reset_password_post
#     raise 'invalid token' unless @user = User.authenticate_by_recovery_token(params[:token])
#     post
#   end
# 
# == Example
# 
# In your migration, create a user model with the appropriate columns. It is
# recommended to create a unique key over the record identifiers. Note that
# this example assumes the usage of I10::ActiveRecord::CuteIndexes.
# 
#   class CreateUsers < ActiveRecord::Migration
#     def self.up
#       create_table :users do |t|
#         t.string :email,          :unique => true
#         t.string :login,          :unique => true
#         t.string :salt,           :length => 40
#         t.string :password_hash,  :length => 40
#         t.string :token,          :length => 40
#         t.string :recovery_token, :length => 40
#       end
#     end
#   
#     def self.down
#       drop_table :users
#     end
#   end
# 
# Then declare the model as authenticating:
# 
#   class User < ActiveRecord::Base
#     authenticates
#   end
# 
# Now, you can use the authentication methods in your controller. Note that
# this example assumes the use of I10::ActionController::Restful.
# 
#   class MyController < ActionController::Base
#     def login_post
#       @user = User.authenticate params[:user]
#     end
#   end
# 
# The login view should use a simple form_for form. Note that this example
#  assumes the use of I10::ActionView::CuteFormBuilder.
# 
#   <% form_for :user do |f| %>
#     <% f.login 'Login Name:' %>
#     <% f.password 'Password:' %>
#   <% end %>
# 
# This is all the code you need to allow authentication.
# 
# == The Magic
# 
# 
module I10::ActiveRecord::AuthenticatedUser
  ENCRYPT_JOIN_STRING = '%%'
  
  # Makes an ActiveRecord authenticate
  def authenticates
    
    class_eval do
      
      # create a password attribute if none present
      # old version: self.class.columns_hash - self.class always returns Class if self is no instance object
      attr_accessor :password unless self.columns_hash[:password]
      
      # class methods
      class << self

        # authenticate by an options hash or email or login with password
        def authenticate(options_or_email_or_login, password = nil)
          
          # parameter is a hash
          if options_or_email_or_login == Hash
            cond = options_or_email_or_login
          
          # parameter is a string
          else
            # old version: self.class.email_match - see above
            key = (self.email_match =~ options_or_email_or_login) ? :email : :login
            cond = { key => options_or_email_or_login, :password => password }
          end
          
          # check for password later
          password = cond.delete :password
          
          # retrieve the record
          record = self.find :first, :conditions => cond
          
          # authenticate
          record.authenticate password
        end
      
        # authenticate by token
        def authenticate_by_token(token)
          raise 'Token cannot be empty' unless token
          # old version - self.class.find - see above
          record = self.find :first, :token => token
        end
        
        # authenticate by recovery token
        def authenticate_by_recovery_token(token)
          raise 'Token cannot be empty' unless token
          # old version - self.class.find - see above
          record = self.find :first, :recovery_token => token
        end
        
        # encrypt anything
        def encrypt(*args)
          require 'digest/sha1'
          Digest::SHA1.hexdigest args.join(ENCRYPT_JOIN_STRING)
        end
        
        # generate a random token
        def create_token
          encrypt rand(), Time.now, object_id
        end
      
      end
      
      # authenticate by password
      def authenticate(password)
        password_hash == encryp(password)
      end
      
      # create token
      def create_token
        self.token = self.class.create_token
      end
      
      # create token and save
      def create_token!
        create_token
        save!
        token
      end
      
      # clear token
      def clear_token
        self.token = nil
      end
      
      # clear token and save
      def clear_token!
        clear_token
        save!
      end
      
      # create recovery token
      def create_recovery_token
        self.token = self.class.create_token
      end
      
      # create recovery token and save
      def create_recovery_token!
        create_recovery_token
        save!
        recovery_token
      end
      
      # clear recovery token
      def clear_recovery_token
        self.token = nil
      end
      
      # clear recovery token and save
      def clear_recovery_token!
        clear_recovery_token
        save!
      end
      
      # encrypt something with stored salt
      def encrypt(string)
        return false unless salt
        self.class.encrypt salt, string
      end
      
      # generate new salt
      def create_salt
        self.salt = self.class.create_token
      end
      
      # encrypt the password
      def encrypt_password
        return unless password
        create_salt unless salt
        clear_recovery_token
        encrypt password
      end
      before_save :encrypt_password
      
    end
    
  end
  
  
end