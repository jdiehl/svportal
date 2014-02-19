class AddContractToConference < ActiveRecord::Migration
  def self.up
    add_column :conferences, :contract, :text
  end

  def self.down
    remove_column :conferences, :contract
  end
end
