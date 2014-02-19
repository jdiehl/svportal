class CreateMails < ActiveRecord::Migration
  def self.up
    create_table :mails do |t|
      t.integer  :conference_id, :null => false
      t.string   :from, :null => false
      t.integer  :to
      t.string   :subject, :null => false
      t.text     :text, :null => false
      t.integer  :status
      t.string   :custom
      t.timestamps
    end
    add_foreign_key :mails, :conference_id, :conferences
    add_index :mails, :created_at
    add_index :mails, :subject
  end

  def self.down
    drop_table :mails
  end
end
