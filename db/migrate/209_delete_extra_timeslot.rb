class DeleteExtraTimeslot < ActiveRecord::Migration
  def self.up
    Timeslot.delete_all :start_time => nil, :end_time => nil
  end

  def self.down
    Timeslot.create :start_time => nil, :end_time => nil, :any_time => true
  end
end
