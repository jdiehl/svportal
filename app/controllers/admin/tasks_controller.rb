class Admin::TasksController < AdminController
  include I10::ActionController::Restful
  controls_active_record :task
  
  # index
  def index
    # day and tasks from params
    @day = @conference.day params[:id] if params[:id]
    if @day
      @order = update_session(:tasks_order, params[:order], 'start_time')
      order_add = (@order == 'start_time' ? '' : ',start_time') + ',end_time,name'
      # prepare option hash
      options = {}
      options[:order] = @order + order_add
      options[:search] = params[:search] if params[:search]
      @tasks = @day.tasks options
    end
    @search = params['search']
  end
  
  # request to edit a task
  def edit
    @task = Task.find params[:id] if params[:id]
    @task ||= Task.new :day => params[:d]
  end
  
  def edit_post
    raise 'need task' unless params[:task]
    params[:task]['invisible'] ||= 0
    params[:task]['conference_id'] = @conference.id
    params[:id] = nil if params[:commit] == 'Save as copy'
    post
  end

  def post
    return put if params[:id] or instance_variable_get('@%s' % active_record_name)
    raise 'need attributes' unless attributes = params[active_record_name]
    r = active_record_class.new attributes
    record = active_record_class.create attributes
    instance_variable_set '@%s' % active_record_name, record
    render_restful
  end
  
  protected
  
  # after creating a new task
  def render_post
    # we are valid -> return to list
    return redirect_to(:action => 'index', :id => @task.day, :search => params['search']) if @task.errors.empty?
    
    # display errors
    render :action => 'edit'
  end
  
  def render_delete
    # return to overview
    render :action => 'index', :id => @task.day
  end
  
  # must be admin to use this controller
  before_filter :require_admin
  def require_admin
    raise 'unauthorized' unless @admin_user.admin?
  end

end