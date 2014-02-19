class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :conference_id, :null => false
      t.string  :name, :null => false
      t.text    :description, :null => false
      t.string  :location
      t.integer :day, :null => false
      t.time    :start_time, :null => false
      t.time    :end_time, :null => false
      t.integer :slots, :null => false
      t.float   :hours, :null => false
      t.integer :priority, :null => false
      t.integer :invisible, :null => false, :default => 0
      t.timestamps
    end
    add_foreign_key :tasks, :conference_id, :conferences
    add_index :tasks, [:start_time, :end_time, :name]
  end

  def self.down
    drop_table :tasks
  end
end
