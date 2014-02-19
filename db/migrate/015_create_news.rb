class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.integer  :conference_id, :null => false
      t.string   :title, :null => false
      t.text     :text, :null => false
      t.timestamps
    end
    add_foreign_key :news, :conference_id, :conferences    
  end

  def self.down
    drop_table :news
  end
end
