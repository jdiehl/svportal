class EnrollmentController < ApplicationController
  before_filter :require_login
  
  # show the waitlist
  def waitlist
    raise 'unauthorized' unless @conference.waitlist_enabled?
    @accepted = @conference.accepted
    @waitlist = @conference.waitlist
  end
  
  # ask to enroll
  def enroll
    # redirect to user/profile if incomplete
    unless @user.valid?
      flash[:notice] = 'Please complete your profile before enrolling'
      return redirect_to(:controller => 'user', :action => 'profile')
    end
  end
  
  # enroll user in conference
  def enroll_post
    raise 'enrollment disabled' unless @conference.open_enrollment?
    @user.enroll_in_conference @conference, params['enroll']
    redirect_to :action => 'enroll_done'
  end
  
  # confirmation
  def enroll_done
  end
  
  # ask to unenroll
  def unenroll
  end
      
  # remove enrollment
  def unenroll_post
    @enroll.drop!
    redirect_to :action => 'unenroll_done'
  end
  
  # confirmation
  def unenroll_done
  end
  
end
