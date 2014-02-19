class TasksController < ApplicationController
  before_filter :require_registered, :require_enabled

  include I10::ActionController::Restful
  controls_active_record :bid

  # lists all tasks (for a specific day)
  def index
    @day = @conference.day(params[:day] ? params[:day] : 1)
    raise 'invalid day' unless @day.date
    @tasks = @day.tasks_with_bids_and_assignments @enroll
    render :partial => 'task', :collection => @tasks if request.xhr?
  end
  
  # update a bid
  def index_post
    raise 'need bid' unless params[:bid]
    # secure binding to current user
    params[:bid][:enrollment_id] = @enroll.id
    # secure the right bid is updated (if update)
    @bid = Bid.find :first, :conditions => {:enrollment_id => @enroll.id, :task_id => params[:bid][:task_id]}
    post
  end
  
  # delete a bid
  def index_delete
    raise 'need bid' unless params[:bid]
    @bid = Bid.find :first, :conditions => {:enrollment_id => @enroll.id, :task_id => params[:bid][:task_id]}
    return render(:nothing => true) unless @bid
    delete
  end
  
  # renders a list with all assigned tasks
  def assignments
    @assignments = @enroll.assignments_with_tasks
  end
  
  # bid on all remaining tasks (i.e. tasks I've not bidden for and that aren't full)
  def bid_all_post
    raise 'need day' unless params[:day]
    @day = @conference.day params[:day]
    Bid.bid_on_remaining_tasks_for_day_and_user(@day, @enroll)
    redirect_to :action => 'index', :day => params[:day]
  end
  
  # clear all bids for this day
  def bid_none_post
    raise 'need day' unless params[:day]
    @day = @conference.day params[:day]
    Bid.remove_bids_for_day_and_user(@day, @enroll)
    redirect_to :action => 'index', :day => params[:day]
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