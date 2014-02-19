class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.column :code, :string, :limit => 2
      t.column :name, :string
    end
    add_index :countries, :name
  end

  def self.down
    drop_table :countries
  end
end
