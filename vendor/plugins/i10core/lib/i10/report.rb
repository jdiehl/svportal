# I10::Report is a base class for defining ActiveRecords that are not
# representative for a single table, but instead span over multiple tables
# to show aggregated information about the database.
# 
# Reports may be constructed using joins or custom SQL queryies.
# 
# The class makes sure that retrieved objects cannot be changed.
# 
# == Example
# 
# To read users and groups and countries, the following optimized sql
# statement can be used:
# 
#   I10::Report.find_by_sql 'select u.name, u.email, c.name country, g.name group from users'
# 
class I10::Report < ActiveRecord::Base
  # virtual record with no columns
  def self.columns # :nodoc:
    []
  end
  
  # report records are strictly read-only!
  def readonly? # :nodoc:
    true
  end
  
end