require 'fastercsv'

# Extends the Hash class with several useful methods
# 
module I10::ActiveSupport::ArrayExtension
  
  # on inclusion
  def self.included(base) # :nodoc
    base.class_eval do
      
      alias to_csv_without_active_record to_csv
      # export to csv string
      # 
      # requires FasterCSV gem and overrides their to_csv method for arrays
      # 
      # ==== Parameters
      # 
      # * options: (optional) FasterCSV options hash with some extensions:
      #   :col_sep: defaults to ;
      def to_csv(options = {})
        options[:col_sep] ||= ';'
        
        # using to_csv method
        if first.respond_to? :to_csv
          r = first.to_csv options, true
          each { |a| r << a.to_csv(options) }
          return r
        
        # ActiveRecords
        elsif first.is_a? ActiveRecord::Base
          FasterCSV.generate(options) do |csv|
            csv << first.attributes.keys
            each { |a| csv << a.attribues.values }
          end
        
        # everything else
        else
          return to_csv_without_active_record(options)
        end
      end

    end
  end
  
end
