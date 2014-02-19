class AdminController < ActionController::Base

  # index: redirect to admin/conference
  def index
    redirect_to :controller => 'admin/conference'
  end
  
  # login
  def login
    render :layout => false
  end
  
  # perform login
  def login_post
    user = AdminUser.authenticate params[:admin_user]

    # store login in session
    session[:user] = user.id
    session[:conference] = user.conference_id
    
    # redirect appropriately
    redirect_params = session[:redirect_params]
    session[:redirect_params] = nil
    redirect_params ||= {:controller => 'admin/conference', :action => 'index'}
    redirect_to redirect_params

  # invalid login
  rescue => error
    @flash = 'Wrong password or username!'
    @admin_user = AdminUser.new params[:admin_user]
    @admin_user.password = ''
    render :action => 'login', :layout => false
  end
  
  # logout
  def logout
    session[:user] = nil
    session[:conference] = nil
    redirect_to :action => 'login'
  end
  
  protected
  
  # authentication
  # required before all non-login actions
  before_filter :authenticate, :except => [:login, :login_post, :logout]
  def authenticate
    @admin_user = AdminUser.find session[:user]
    if session[:conference]
      @conference = Conference.find session[:conference]
    else
      @conference = Conference.find_by_short_name params[:conference_name]
    end
  rescue
    session[:redirect_params] = params
    redirect_to :controller => '/admin', :action => 'login'
    return false
  end
  
  # update a session value
  def update_session(key, new_value, default_value = nil)
    session[key] = new_value unless new_value.nil?
    session[key] = default_value if session[key].nil?
    session[key].nil? ? default_value : session[key]
  end
  
  # do not render layout on xhr requests
  def render(options = {})
    options[:layout] = request.xhr? ? false : 'admin' unless options.key? :layout or request.parameters['action'] == 'dump'
    super options
  end
  
end
