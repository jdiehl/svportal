class Availability < ActiveRecord::Base

  # delete all availability info of one user
  def self.remove_avails_for_user(conference, enroll)
    Availability.delete_all 'enrollment_id=%i and conference_id=%i' % [enroll.id, conference.id]
  end

end
