class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.integer :user_id, :null => false
      t.integer :conference_id, :null => false
      t.integer :status, :null => false, :default => 0
      t.integer :lottery
      t.string  :comment
    end
    add_foreign_key :enrollments, :user_id, :users
    add_foreign_key :enrollments, :conference_id, :conferences
    add_index :enrollments, [:conference_id, :user_id], :unique => true
    add_index :enrollments, [:conference_id, :status, :lottery]
  end

  def self.down
    drop_table :enrollments
  end
end
