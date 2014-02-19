class AddTimeslots < ActiveRecord::Migration
  def self.up
    start = Time.local(1970, "Jan", 1, 0, 0, 0)
    7.upto 21 do |hour|
      Timeslot.create :start_time => start + hour * 3600, :end_time => start + (hour+1) * 3600, :any_time => false
    end
    Timeslot.create :start_time => nil, :end_time => nil, :any_time => true
  end

  def self.down
    execute 'truncate timeslots'
  end
end
