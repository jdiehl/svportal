# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  filter_parameter_logging :password, :password_confirmation
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :load_conference, :except => [:select_conference, :select_conference_post, :maintenance]
  before_filter :load_user, :except => [:send_password, :send_password_post]
  
  ### protected methods ###
  protected
  
  # load the conference
  def load_conference
    @conference_name = params[:conference_name]
    unless @conference = Conference.find_by_short_name(@conference_name)
      redirect_to root_path
      return false
    end
    redirect_to :controller => 'main', :action => 'maintenance' if @conference.maintenance
  end

  # load the logged in user
  def load_user
    @user = User.find session[:uid] if session[:uid]
    @enroll = @user.enrollment_for_conference(@conference) if @user and @conference
  rescue
    session[:uid] = nil
  end
  
  # are we logged in?
  helper_method :logged_in?
  def logged_in?
    session[:uid] != nil
  end
  
  # require login
  def require_login
    return true if logged_in?
    redirect_to :controller => 'news', :action => 'index'
    false
  end

end
