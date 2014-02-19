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
    @conference = Conference.new params[:conference]
    @conference.status = 0
    return redirect_to(:conference_name => @conference.short_name, :controller => 'admin_conference', :action => 'index') if @conference.save
    render :add
  end
  
  # private methods
  
  def require_super_admin
    raise 'unauthorized' unless @admin_user.super_admin?
  end
  
end
