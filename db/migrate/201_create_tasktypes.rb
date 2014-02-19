class CreateTasktypes < ActiveRecord::Migration
  def self.up
    create_table :tasktypes do |t|
      t.string :name
      t.string :description
      t.integer :conference_id
      t.timestamps
    end
    add_column :tasks, :tasktype_id, :integer
    add_column :bids, :tasktype_id, :integer
    add_foreign_key :tasks, :tasktype_id, :tasktypes
    add_foreign_key :bids, :tasktype_id, :tasktypes
    add_foreign_key :tasktypes, :conference_id, :conferences
  end

  def self.down
    drop_table :tasktypes
    remove_column :tasks, :tasktype_id
  end
end
