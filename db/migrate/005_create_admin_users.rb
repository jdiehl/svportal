class CreateAdminUsers < ActiveRecord::Migration
  def self.up
    create_table :admin_users do |t|
      t.string  :login, :limit => 40, :null => false
      t.string  :password_hash, :limit => 40
      t.string  :salt, :limit => 40
      t.integer :conference_id
      t.integer :status
    end
    add_index :admin_users, :login, :unique => true
    add_index :admin_users, :password_hash
    add_foreign_key :admin_users, :conference_id, :conferences
  end

  def self.down
    drop_table :admin_users
  end
end
