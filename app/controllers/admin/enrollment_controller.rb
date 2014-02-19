class Admin::EnrollmentController < AdminController
  VALID_ORDERS = %w{users.last_name users.university users.home_country_id users.spoken_languages users.past_conferences lottery}
  
  include I10::ActionController::Restful
  controls_active_record :enrollment

  # index
  def index
    @status = @conference.enrollment_status params[:id] if params[:id]
    @order = update_session :enrollment_order, params[:order], 'users.last_name'
    @order = update_session :enrollment_order, 'users.last_name', 'users.last_name' unless VALID_ORDERS.include? @order

    @search = params[:search]
    
    # conditions
    cond = ['conference_id=%i' % @conference.id]
    cond << 'status=%i' % @status.id if @status
    cond << Enrollment.search_conditions(params[:search]) if params[:search]
    
    @enrollments = Enrollment.paginate :page => params[:page],
      :include => :user,
      :order => @order,
      :conditions => cond.join(' and ')
  end
  
  # list emails
  def email
    @status = @conference.enrollment_status params[:id] if params[:id]
    @search = params[:search]
    @order = update_session :enrollment_order, params[:order], 'users.last_name'
    
    # conditions
    cond = ['conference_id=%i' % @conference.id]
    cond << 'status=%i' % @status.id if @status
    cond << Enrollment.search_conditions(params[:search]) if params[:search]
    
    @enrollments = Enrollment.find :all, :include => :user, :order => @order, :conditions => cond.join(' and ')
  end
  
  # edit or create a user
  def user
    if params[:id]
      @user = User.find params[:id]
      @enroll = @user.enrollment_for_conference @conference
    else
      @user = User.new
    end
  end
  
  # create the user and possibly enroll
  def user_post
    raise 'need user' unless attributes = params[:user]
    @user = User.update params[:id], attributes if params[:id]
    @user ||= User.create attributes
    
    # enroll
    if @user.errors.empty?
      if params[:enroll_status]
        @enroll = Enrollment.enroll_user_in_conference @user, @conference, params[:enroll_status]
      end
    end

    return redirect_to(:action => 'index', :id => params[:status], :search => params[:search]) if @user.errors.empty?
    
    @user.password = @user.password_confirmation = nil
    render :action => 'user'
  end
  
  protected
  
  # after changing enrollment status
  def render_post
    return render(:status => 406, :text => @enrollment.errors.full_messages) unless @enrollment.errors.empty?
    return render(:text => @enrollment.comment) if params[:enrollment][:comment]
    render :partial => 'status', :locals => { :enrollment => @enrollment }
  end
  
  # must be admin to use this controller
  before_filter :require_admin
  def require_admin
    raise 'unauthorized' unless @admin_user.admin?
  end

end
