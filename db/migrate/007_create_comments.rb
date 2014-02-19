class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
        t.integer  :user_id, :null => false
        t.integer  :conference_id, :null => false
        t.integer  :type, :null => false
        t.text     :text, :null => false
        t.decimal  :hours, :null => false, :default => 0
        t.timestamps
      end
      add_foreign_key :comments, :user_id, :users
      add_foreign_key :comments, :conference_id, :conferences
      add_index :comments, :created_at
      add_index :comments, :type
  end

  def self.down
    drop_table :comments
  end
end
