class TimeslotsController < ApplicationController
  #before_filter :require_registered, :require_enabled
  
  include I10::ActionController::Restful
  controls_active_record :availability

  def index
    @timeslots = Timeslot.find :all
    @availabilities = Availability.find :all, :conditions => { :enrollment_id => @enroll.id, :conference_id => @conference.id }
  end

  # update availability
  def index_post
    raise 'need availabilities' unless params[:availabilities]
    @availabilities = params[:availabilities]

    # Delete all availability information for the user.
    Availability.remove_avails_for_user(@conference, @enroll)
    # Save availability information for the user.
    @availabilities.split('|').each do |tsid_avail|
      @tsid = tsid_avail.split(',')[0]
      @dayid = tsid_avail.split(',')[1]
      @conf_day = ConferenceDay.new(@conference, @dayid.to_i)
      Availability.create(:conference_id => @conference.id, :enrollment_id => @enroll.id, :day => @conf_day.date, :timeslot_id => @tsid.to_i)
    end

    render :text => 'success'
  end
end
