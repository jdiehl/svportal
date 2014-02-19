# Adds several useful methods to the ActiveRecord class
# 
module I10::ActiveRecord::ConvenienceMethods
  
  # on inclusion
  def self.included(base) # :nodoc:
    base.class_eval do
      class << self
        
        # regular expression to validate emails with validates_format_of
        # 
        # ==== Example
        # 
        #   validated_format_of :email, :with => email_match
        # 
        def email_match
          /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,6}$/i
        end
        
        # First try to find and return the record matching the given conditions. If no
        # record is found, create a new record.
        # 
        # ==== Parameters
        # 
        # * conditions: the find / create conditions
        def find_or_create(conditions)
          record = Participation.find(:first, :conditions => conditions)
          record ||= Participation.create conditions
        end

      end
    end
  end
  
  # default string representation calls name method if exists
  def to_s
    return name if respond_to? :name
    super
  end
  
  # default integer representation is the id
  def to_i
    id
  end
  
end