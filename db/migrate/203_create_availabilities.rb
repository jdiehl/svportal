class CreateAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :availabilities do |t|
      t.integer :enrollment_id, :null => false
      t.integer :timeslot_id, :null => false
      t.date    :day
      t.boolean :available, :null => false
      t.timestamps
    end
    add_foreign_key :availabilities, :enrollment_id, :enrollments, :id, :on_delete => 'CASCADE'
    add_foreign_key :availabilities, :timeslot_id, :timeslots, :id, :on_delete => 'CASCADE'
  end

  def self.down
    drop_table :availabilities
  end
end
