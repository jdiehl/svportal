class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.integer :enrollment_id, :null => false
      t.integer :task_id, :null => false
      t.float   :hours
      t.integer :status, :null => false, :default => 1
      t.string  :comment
    end
    add_foreign_key :assignments, :enrollment_id, :enrollments
    add_foreign_key :assignments, :task_id, :tasks
    add_index :assignments, [:enrollment_id, :task_id], :unique => true
  end

  def self.down
    drop_table :assignments
  end
end
