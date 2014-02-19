class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.integer :enrollment_id, :null => false
      t.integer :task_id,       :null => false
      t.integer :preference,    :null => false, :default => 1
      t.integer :status,        :null => false, :default => 1
    end
    add_foreign_key :bids, :enrollment_id, :enrollments, :id, :on_delete => 'CASCADE'
    add_foreign_key :bids, :task_id, :tasks, :id, :on_delete => 'CASCADE'
    add_index :bids, :preference
    add_index :bids, [:enrollment_id, :task_id], :unique => true
  end

  def self.down
    drop_table :bids
  end
end
