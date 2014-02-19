# Allow exporting ActiveRecord data to csv
# 
# == Example
# 
#   def csv
#     @items = Item.find :all
#     render_csv @items
#   end
# 
# The above action will render something like the following:
# 
#   id;name;group_id
#   1;Orange Juice;1
#   2;Milk;1
#   3;Coffee;1
#   4;Bread;2
#   5;Butter;2
# 
# See the FasterCSV gem documentation for a complete reference of the output
# options and conventions.
# 
# http://fastercsv.rubyforge.org
module I10::ActionController::RenderCsv
  
  # Export an Array of ActiveRecords as csv
  # 
  # relys on to_csv from I10::ActiveSupport::ArrayExtension
  # 
  # ==== Parameters
  # 
  # * items: Array of ActiveRecords
  # * filename: (optional) export file name
  # * options: (optional) FasterCSV generator options (:col_sep defaults to ';')
  def render_csv(items, filename = nil, options = {})
    filename = items.first.class.name.pluralize.dasherize + '.csv'
    send_data items.to_csv(options),
      :type => 'text/csv; charset=utf-8; header=present',
      :filename => filename
  end
  
end