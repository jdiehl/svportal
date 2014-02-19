class AddReasonToEnrollment < ActiveRecord::Migration
  def self.up
    add_column :enrollments, :reason, :text
    add_column :lottery_configs, :reason, :integer, :default => 0
  end

  def self.down
    remove_column :enrollments, :reason
    remove_column :lottery_configs, :reason
  end
end
