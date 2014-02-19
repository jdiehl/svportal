# Allows easy searching of ActiveRecords
# 
# == Example
# 
# The columns that should be included in the search are defined in the model:
# 
#   class User < ActiveRecord::Base
#     searchable :name, :email
#   end
# 
# Now, the :search option is available for the find operation:
# 
#   class MyController < ActionController::Base
#     def index
#       @users = User.find :all, :search => params[:search]
#     end
#   end
# 
# == The Magic
# 
# Searchable adds a string to the conditions statement to the given query
# that goes through all given columns and matches them against the search
# string using the SQL LIKE statement.
# 
# Searchable applies to all finding and calculating (count) methods. It does
# not apply to find_by_sql!
# 
module I10::ActiveRecord::Searchable
  
  # define what fields should be searched
  def searchable(columns) # :nodoc:
    @_search_columns = columns
    
    class_eval do
      class << self

        # we need to allow :search as a find option
        VALID_FIND_OPTIONS << :search
        
        # Retrieve search conditions
        # 
        # Search conditions are represented by a string containing all columns
        # that need to be searched with the LIKE operator.
        # 
        # Avoid calling this method directly - use the :search parameter for
        # the find operation instead.
        # 
        # ==== Parameters
        # 
        # * search_string: string to be searched
        # * columns: (optional) override the predefined columns
        def search_conditions(search_string, columns = nil)
          return '' unless search_string
          columns ||= @_search_columns
          raise 'no search columns given' unless columns
          quoted_string = connection.quote_string search_string
          cond = columns.collect { |k|"%s like '%%%s%%'" % [k, quoted_string] }
          '(%s)' % cond.join(' or ')
        end

        alias find_every_without_search find_every
        # override find_every method to include search
        def find_every(options) # :nodoc:
          if search_string = options.delete(:search)
            options[:conditions] = options[:conditions] ? '(%s) AND ' % sanitize_sql(options[:conditions]) : ''
            options[:conditions] += search_conditions(search_string)
          end
          find_every_without_search options
        end

        alias calculate_without_search calculate
        # override calculate method to include search
        def calculate(operation, column_name, options = {}) # :nodoc:
          if search_string = options.delete(:search)
            options[:conditions] = options[:conditions] ? '(%s) AND ' % sanitize_sql(options[:conditions]) : ''
            options[:conditions] += search_conditions(search_string)
          end
          calculate_without_search operation, column_name, options
        end
      
      end
    end
  end
  
end