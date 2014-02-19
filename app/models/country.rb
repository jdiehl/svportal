class Country < ActiveRecord::Base
  @@countries = []
  
  # return all countries in order
  def self.all
    return @@countries unless @@countries.empty?
    @@countries = find :all, :order => 'name'
  end
  
  def to_s
    name
  end
end
