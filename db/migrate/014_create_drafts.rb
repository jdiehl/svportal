class CreateDrafts < ActiveRecord::Migration
  def self.up
    create_table :drafts do |t|
      t.integer :conference_id, :null => false
      t.integer :event
      t.string  :subject,       :null => false
      t.text    :text,          :null => false
      t.timestamps
    end
    add_index :drafts, [:event, :conference_id], :unique => true
    add_index :drafts, :subject
    add_foreign_key :drafts, :conference_id, :conferences
  end

  def self.down
    drop_table :drafts
  end
end
