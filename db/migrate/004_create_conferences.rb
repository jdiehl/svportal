class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.string  :name, :null => false, :default => 'unnamed'
      t.string  :short_name, :null => false, :default => 'unnamed'
      t.integer :year
      t.string  :email, :null => false
      t.integer :volunteers, :null => false, :default => 40
      t.integer :volunteer_hours, :null => false, :default => 20
      t.date    :start_date
      t.date    :end_date
      t.integer :bid_day
      t.integer :status
      t.boolean :maintenance, :default => false
      t.timestamps
    end
    add_index :conferences, [:year, :name], :unique => true
  end

  def self.down
    drop_table :conferences
  end
end
