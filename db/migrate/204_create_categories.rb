class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
      t.integer :conference_id
      t.timestamps
    end
    
    add_column :tasktypes, :category_id, :integer
    add_foreign_key :tasktypes, :category_id, :categories
    add_foreign_key :categories, :conference_id, :conferences
  end

  def self.down
    drop_table :categories
    remove_column :tasktypes, :category_id
  end
end
