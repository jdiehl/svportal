class Timeslot < ActiveRecord::Base
  has_many :availabilities
end
