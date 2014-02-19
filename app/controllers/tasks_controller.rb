class TasksController < ApplicationController
  before_filter :require_registered, :require_enabled

  include I10::ActionController::Restful
  controls_active_record :bid

  # lists all task types
  def index
    query = 'SELECT t.*, c.name as category_name, a.status as assignment_status, b.status as bid_status, b.preference as bid_preference FROM tasktypes t '
    query +='JOIN categories c ON t.category_id = c.id '
    query +='JOIN conferences cn ON t.conference_id = cn.id '
    query +='LEFT JOIN assignments a ON a.task_id = t.id AND a.enrollment_id=%i ' % @enroll.id
    query +='LEFT JOIN bids b ON b.tasktype_id = t.id AND b.enrollment_id=%i ' % @enroll.id
    query +='WHERE t.conference_id=%i ' % [@conference.id]
    query +='ORDER BY name'
    
    @tasktypes = Tasktype.find_by_sql query
    @categories = Category.find :all, :conditions => { :conference_id => @conference.id }
    render :partial => 'tasktype', :collection => @tasktypes if request.xhr?
  end
  
  # Save bids
  def index_post
    raise 'need bids' unless params[:bids]
    @bids = params[:bids]

    if Bid.validate_preference_limit(@bids) then
      # Delete all bids by user.
      Bid.remove_bids_for_user(@conference, @enroll)
      # Save all bids by user.
      @bids.split('|').each do |ttid_bid|
        @ttid = ttid_bid.split(',')[0]
        @pref = ttid_bid.split(',')[1]
        Bid.create(:enrollment_id => @enroll.id, :status => Bid::OPEN, :preference => @pref.to_i, :tasktype_id => @ttid.to_i) if @pref.to_i > 0
      end

      render :text => 'success'
    else
      render :text => 'Bidding restrictions failed.'
    end
  end
  
  # renders a list with all assigned tasks
  def assignments
    @assignments = @enroll.assignments_with_tasks
  end
  
  # bid on all remaining tasks (i.e. tasks I've not bidden for and that aren't full)
  def bid_all_post
    Bid.bid_on_remaining_tasks_for_user(@conference, @enroll)
    redirect_to :action => 'index'
  end
  
  # clear all bids for this day
  def bid_none_post
    Bid.remove_bids_for_user(@conference, @enroll)
    redirect_to :action => 'index'
  end
  
  protected
  
  def require_registered
    return false unless require_login
    unless @enroll.registered?
      redirect_to :controller => 'news'
      return false
    end
  end
  
  def require_enabled
    unless @conference.bidding_enabled?
      redirect_to :controller => 'news'
      return false
    end
  end
end