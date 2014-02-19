class Admin::TasktypesController < AdminController
  include I10::ActionController::Restful
  controls_active_record :tasktype
  
  # list
  def index
    query = 'select t.*, c.name as category_name from tasktypes t join categories c on (t.category_id = c.id)'
    @tasktypes = Tasktype.find_by_sql query
  end

  # edit
  def edit
    @tasktype = Tasktype.find params[:id] if params[:id]
    @tasktype ||= Tasktype.new :conference_id => @conference.id
  end
  
  # add conference_id
  def edit_post
    raise 'need tasktype' unless params[:tasktype]
    params[:tasktype][:conference_id] = @conference.id
    post
  end
  
  def edit_done
    redirect_to :action => 'index'
  end
  
  protected
  
  # after editing
  def render_post
    return redirect_to(:action => 'index') if @tasktype.errors.empty?
    render :action => 'edit'
  end
  
  # must be admin to use this controller
  before_filter :require_admin
  def require_admin
    raise 'unauthorized' unless @admin_user.admin?
  end

end