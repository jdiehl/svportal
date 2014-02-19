class CreateTshirtSizes < ActiveRecord::Migration
  def self.up
    create_table :tshirt_sizes do |t|
      t.string  :name
      t.integer :order
    end
    add_index :tshirt_sizes, :order
  end

  def self.down
    drop_table :tshirt_sizes
  end
end
