class ModifyBids < ActiveRecord::Migration
  def self.up
    remove_index :bids, [:enrollment_id, :task_id]
    execute 'alter table bids drop foreign key `bids_ibfk_2`'
    remove_column :bids, :task_id
    add_index :bids, [:enrollment_id, :tasktype_id], :unique => true
  end

  def self.down
    add_column :bids, :task_id, :integer
    add_foreign_key :bids, :task_id, :tasks, :id, :on_delete => 'CASCADE'
    add_index :bids, [:enrollment_id, :task_id], :unique => true
  end
end
