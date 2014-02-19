class Admin::SvLoginController < AdminController
  
  def index
    @status = @conference.enrollment_status params[:id] if params[:id]
    @order = update_session :enrollment_order, params[:order], 'users.last_name'
    
    # conditions
    cond = ['conference_id=%i' % @conference.id]
    cond << 'status=%i' % @status.id if @status
    cond << User.search_conditions(params[:search]) if params[:search]
    
    @enrollments = Enrollment.paginate :page => params[:page],
      :include => :user,
      :order => @order,
      :conditions => cond.join(' and ')
  end
  
  def go
    raise 'need id' unless params[:id]
    user = User.find params[:id]
    session[:uid] = user.id
    return redirect_to(:controller => '/main', :action => 'index')
  end
  
end
