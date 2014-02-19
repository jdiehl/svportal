class Admin::CategoriesController < AdminController
  include I10::ActionController::Restful
  controls_active_record :category
  
  # list
  def index
    options = {
        :conditions => { :conference_id => @conference.id }, 
    }
    @categories = Category.find :all, options
  end

  # edit
  def edit
    @category = Category.find params[:id] if params[:id]
    @category ||= Category.new :conference_id => @conference.id
  end
  
  # add conference_id
  def edit_post
    raise 'need category' unless params[:category]
    params[:category][:conference_id] = @conference.id
    post
  end
  
  def edit_done
    redirect_to :action => 'index'
  end
  
  protected
  
  # after editing
  def render_post
    return redirect_to(:action => 'index') if @category.errors.empty?
    render :action => 'edit'
  end
  
  # must be admin to use this controller
  before_filter :require_admin
  def require_admin
    raise 'unauthorized' unless @admin_user.admin?
  end

end