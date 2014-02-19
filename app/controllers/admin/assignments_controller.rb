class Admin::AssignmentsController < AdminController
  include I10::ActionController::Restful
  controls_active_record :assignment
  
  ENROLLMENT_REGISTERED = [Status::REGISTERED, Status::ONSITE].join ','
  before_filter :calc_hours

  def index
    # day and tasks from params
    @day = @conference.day params[:id] if params[:id]
    
    # fetch ordered tasks data
    if @day
      @order = update_session :assignments_order, params[:order], 'start_time'
      order_add = (@order == 'start_time' ? '' : ',start_time') + ',end_time,name'
      options = { :order => @order+order_add, :search => params[:search] }
      @tasks = @day.tasks_with_assignments options
    end
  end
  
  # confirm to run auction for the day
  def auction
    raise 'need day' unless params[:id].to_i > 0
    @day = @conference.day params[:id]
  end
  
  # run the auction
  def auction_post
    raise 'need day' unless params[:id].to_i > 0
    @day = @conference.day params[:id]
    @auction = Auction.new @day
    @auction.run
    render :text => 'Auction was run successfully.'
  end
  
  # show users list
  def users
    raise 'need id' unless params[:id]
    @task = Task.find params[:id]
    @users = @task.users_with_bids_and_assignments params[:search]
    render :partial => 'users', :object => @users
  end
  
  # show hours dialog
  def hours
    raise 'need id' unless params[:id]
    @assignment = Assignment.find params[:id]
    @assignment.hours = @assignment.task_hours unless @assignment.hours
    render :partial => 'hours_box'
  end
  
  # cycle the status
  def cycle_status_post
    raise 'need id' unless params[:id]
    @assignment = Assignment.find params[:id]
    @assignment.cycle_status
    render :json => { :id => @assignment.status, :name => @assignment.status_name }
  end
  
  protected
  
  def render_post
    render :partial => 'slots', :locals => {:task => @assignment.task} 
  end
  
	def render_delete
    render :partial => 'slots', :locals => {:task => @assignment.task}
	end
  	
  # must be moderator to use this controller
  before_filter :require_moderator
  def require_moderator
    raise 'unauthorized' unless @admin_user.moderator?
  end
  
  
  
  protected
  
  # calculate total assigned hours for all SVs,
  # don't recalculate on async. calls (what slow system down!)
  def calc_hours
    if request.xhr?
      # nicht neu berechnen
      @hours_report = session[:hours_report]
    else
      # neu berechnen
      @hours_report = {}
      enrolls_with_calc_data = find_all_total_hours @conference
      enrolls_with_calc_data.each do |x|
        hours = x.hours_total
        idx = x.id
        @hours_report[idx] = x.hours_total.to_s
      end
      update_session :hours_report, @hours_report
    end
  end
  
  # calculate total assigned hours for all enrolled
  def find_all_total_hours(conference)
    query = 'select e.id, ' +
      '(select sum(hours) from assignments a where a.enrollment_id = e.id) as hours_total ' +
      'from enrollments e ' +
      'where e.conference_id = %i and e.status in (%s) ' % [conference.id, ENROLLMENT_REGISTERED]
    Enrollment.find_by_sql query
  end

end