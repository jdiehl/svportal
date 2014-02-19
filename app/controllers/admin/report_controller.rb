class Admin::ReportController < AdminController
  
  def index
  end
  
  # hours per task
  def task_hours
    @days = @conference.days
  end
  
  # hours per user
  def user_hours
    @order = update_session :user_hours_order, params[:order], 'last_name'
    @users = Report::UserHours.find @conference, params[:search], @order
  end
  
  # user details
  def user
    raise 'need id' unless params[:id]
    @enroll = Enrollment.find params[:id]
  end
  
  # task details
  def task
    raise 'need id' unless params[:id]
    @task = Task.find params[:id]
  end
  
  # tshirt overview and complete listing
  def tshirt
    @overview = Report::TshirtSizes.find @conference
    @enroll = Enrollment.find :all,
      :conditions => 'conference_id = %i and status >= %i' % [@conference.id, Status::ACCEPTED],
      :include => :user,
      :order => 'users.id, users.last_name, users.first_name'
  end
  
  # complete task list
  def tasks
    @tasks = Task.find :all, :conditions => { :conference_id => @conference.id }, :order => 'day'
  end
  
end
