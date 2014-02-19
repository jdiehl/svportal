class Admin::DraftsController < AdminController
  include I10::ActionController::Restful
  controls_active_record :draft

  # list drafts
  def index
    @order = update_session :drafts_order, params[:order], 'event'
    @order = 'ISNULL(event),%s' % @order if /event/ =~ @order
    options = {
        :conditions => { :conference_id => @conference.id }, 
        :order => @order
    }
    @drafts = Draft.find :all, options
  end

  # edit draft
  def edit
    @draft = Draft.find params[:id] if params[:id]
    @draft ||= Draft.new :conference_id => @conference.id
  end

  # add conference_id
  def edit_post
    raise 'need draft' unless params[:draft]
    params[:draft][:conference_id] = @conference.id
    post
  end
  
  def edit_done
    redirect_to :action => 'index'
  end
  
  protected
  
  # after editing
  def render_post
    return redirect_to(:action => 'index') if @draft.errors.empty?
    render :action => 'edit'
  end
end
