class Admin::AdminConferenceController < AdminController
  before_filter :require_super_admin
  
  # list conferences
  def index
    @conferences = Conference.find :all, :order => 'year desc, id desc'
  end
  
  # add conference
  def add
    @conference = Conference.new params[:conference]
  end
  
  # create added conference
  def add_post
    
    unless params[:password] == params[:password2]
      @password_wrong = true
      return render(:action => 'add')
    end
    
    # create conference
    @conference = Conference.new params[:conference]
    @conference.status = 0
    return render(:action => 'add') unless @conference.save
      
    # create admin user
    AdminUser.create :login => @conference.short_name, :status => 1, :conference_id => @conference.id, :password => params[:password]
    redirect_to :conference_name => @conference.short_name, :controller => 'admin_conference', :action => 'index'
  end
  
  # private methods
  
  def require_super_admin
    raise 'unauthorized' unless @admin_user.super_admin?
  end
  
end
