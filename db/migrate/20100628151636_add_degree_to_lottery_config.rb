class AddDegreeToLotteryConfig < ActiveRecord::Migration
  def self.up
    add_column :lottery_configs, :degree, :boolean, :default => false
  end

  def self.down
    remove_column :lottery_configs, :degree
  end
end
