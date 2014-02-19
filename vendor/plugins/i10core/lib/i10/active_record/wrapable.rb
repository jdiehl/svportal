# Allow wrapping of attributes of ActiveRecord classes
# 
# == Wrapper Class
# 
# The wrapper class must define two methods:
# 
# * self.in(value): create a wrapper object for the attribute value
# * out: return the attribute value to write it back to the database
# 
# == Example
# 
# Define a wrapper class for a human-readable representation of time:
# 
#   class HumanTime < Time
# 
#     # import method
#     def self.in(time)
#       at time
#     end
#     
#     # export method
#     def out
#       self
#     end
#     
#     # string representation as HH:MM
#     def to_s
#       to_human
#     end
#     
#   end
# 
# Then add the class as a wrapper for a Time attributes
# 
#   class Article < ActiveRecord
#     wrap :created_at, HumanTime
#   end
# 
module I10::ActiveRecord::Wrapable
  
  # wrap an attribute with a class
  # 
  # ==== Parameters
  # 
  # * attribute_name: name of the attribute to be wrapped
  # * class_name: name of the wrapper class
  # 
  def wrap(attribute_name, class_name)
    attribute_name = attribute_name.to_s
    class_name = class_name.name unless class_name.is_a? String
    class_eval "
      def #{attribute_name}
        v = read_attribute(:#{attribute_name})
        #{class_name}.respond_to?(:in) ? #{class_name}.in(v) : #{class_name}.new(v)
      end
      def #{attribute_name}=(v)
        #{class_name}.respond_to?(:in) ? #{class_name}.in(v) : #{class_name}.new(v) unless v.is_a? #{class_name} unless v.nil?
        write_attribute :#{attribute_name}, v.respond_to?(:out) ? v.out : v
      end"
  end
  
end