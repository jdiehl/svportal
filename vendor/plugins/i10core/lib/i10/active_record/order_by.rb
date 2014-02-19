# allow default ordering for ActiveRecords
# 
# == Example
# Simply define order_by in your ActiveRecord class:
# 
#   class User < ActiveRecord::Base
#     order_by :last_name, :first_name
#   end
# 
module I10::ActiveRecord::OrderBy
  
  # on inclusion
  def order_by(*args) # :nodoc:
    order = args.join ','
    
    class_eval <<-EOS
      class << self
      
        alias find_every_without_order find_every
        # override find_every to allow a default order
        def find_every(options) # :nodoc:
          options[:order_by] ||= '#{order}'
          find_every_without_order(options)
        end
      
      end
    EOS
    
  end
  
end