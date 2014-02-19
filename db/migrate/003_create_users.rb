class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :email
      t.string   :password_hash, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :gender, :limit => 1
      t.string   :first_name
      t.string   :last_name
      t.text     :address
      t.string   :phone
      t.string   :university
      t.string   :department
      t.string   :student_number
      t.string   :spoken_languages
      t.string   :past_conferences
      t.string   :city
      t.string   :department
      t.integer  :tshirt_size_id
      t.integer  :home_country_id
      t.integer  :residence_country_id
      t.string   :recovery_token, :limit => 40
      t.string   :remember_token, :limit => 40
      t.timestamps
    end
    add_index :users, :email, :unique => true
    add_index :users, :password_hash
    add_index :users, :recovery_token
    add_index :users, :remember_token
    add_index :users, [:last_name, :first_name]
    add_foreign_key :users, :tshirt_size_id, :tshirt_sizes
    add_foreign_key :users, :home_country_id, :countries
    add_foreign_key :users, :residence_country_id, :countries
  end

  def self.down
    drop_table :users
  end
end
