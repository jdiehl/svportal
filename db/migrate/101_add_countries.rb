require 'FasterCSV'

class AddCountries < ActiveRecord::Migration
  def self.up
    FasterCSV.foreach('db/data/country_data.csv', :col_sep => ',', :headers => true) do |row|
      Country.create :code => row['code'], :name => row['english_name']
    end
  end

  def self.down
    truncate :countries
  end
end
