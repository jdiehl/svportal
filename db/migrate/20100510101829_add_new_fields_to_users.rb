class AddNewFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :degree, :integer
    add_column :users, :past_sv, :string
    
    execute 'update users set past_sv=past_conferences'
    execute 'update users set past_conferences=""'
  end

  def self.down
    execute 'update users set past_conferences=past_sv'

    remove_column :users, :degree
    remove_column :users, :past_sv
  end
end
