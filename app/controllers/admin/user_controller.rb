class Admin::UserController < AdminController
  include I10::ActionController::Restful
  controls_active_record :user

  # index
  def index
    @order = update_session :user_order, params[:order], 'last_name'
    @users = User.paginate :page => params[:page],
      :order => @order,
      :search => params[:search]
    @search = params[:search]
  end
  
  # edit or create a user
  def edit
    if params[:id]
      @user = User.find params[:id]
      @enroll = @user.enrollment_for_conference @conference
    else
      @user = User.new
    end
  end
  
  # create / change the user and possibly enroll
  def edit_post
    post
    
    # enroll
    if @user.errors.empty?
      if params[:enroll_status].to_i == 0
        Enrollment.delete_all :user_id => @user.id, :conference_id => @conference.id
      elsif params[:enroll_status]
        @enroll = Enrollment.enroll_user_in_conference @user, @conference, params[:enroll_status]
      end
    end
  end
  
  protected
  
  def render_post
    return redirect_to(:action => 'index', :search => params['search']) if @user.errors.empty?
    
    @user.password = @user.password_confirmation = nil
    render :action => 'edit'
  end
  
  # must be admin to use this controller
  before_filter :require_admin
  def require_admin
    raise 'unauthorized' unless @admin_user.admin?
  end

end
