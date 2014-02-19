class Admin::NewsController < AdminController
  include I10::ActionController::Restful
  controls_active_record :news

  # list news
  def index
    @order = update_session :news_order, params[:order], 'created_at desc'
    options = {
        :conditions => { :conference_id => @conference.id }, 
        :order => @order
    }
    @news = News.find :all, options
  end

  # edit news
  def edit
    @news = News.find params[:id] if params[:id]
    @news ||= News.new :conference_id => @conference.id, :created_at => Date.today
  end
  
  # add conference_id
  def edit_post
    raise 'need news' unless params[:news]
    params[:news][:conference_id] = @conference.id
    post
  end
  
  def edit_done
    redirect_to :action => 'index'
  end
  
  protected
  
  # after editing
  def render_post
    return redirect_to(:action => 'index') if @news.errors.empty?
    render :action => 'edit'
  end
end
