class CreateTimeslots < ActiveRecord::Migration
  def self.up
    create_table :timeslots do |t|
      t.time    :start_time
      t.time    :end_time
      t.boolean :any_time
      t.timestamps
    end
  end

  def self.down
    drop_table :timeslots
  end
end
