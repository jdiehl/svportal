class MarkAllRegistered < ActiveRecord::Migration
  def self.up
    execute 'update enrollments set status=4'
  end

  def self.down
    execute 'update enrollments set status=1'
  end
end
