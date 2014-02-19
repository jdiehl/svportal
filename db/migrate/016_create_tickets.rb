class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :code, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
    add_foreign_key :tickets, :user_id, :users
  end

  def self.down
    drop_table :tickets
  end
end
