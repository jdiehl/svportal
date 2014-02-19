class Admin::ConferenceController < AdminController
  include I10::ActionController::Restful
  controls_active_record :conference
  
  # index
  def index
  end
  
  # edit form
  def edit
    render :partial => 'conference_form', :locals => {:conference_form => @conference} if request.xhr?
  end
  
  # configure lottery
  def lottery_config
    @lottery_config = @conference.lottery_config
  end
  
  # post configure lottery
  def lottery_config_post
    raise 'need attributes' unless attributes = params['lottery_config']
    @lottery_config = @conference.lottery_config
    unless @lottery_config
      attributes['conference_id'] = @conference.id
      @lottery_config = LotteryConfig.create attributes
    else
      attributes.each { |k,v| @lottery_config.send '%s=' % k, v }
      @lottery_config.save
    end
    render_restful
  end
  
  # confirm to run the lottery
  def lottery
  end
  
  # run the lottery
  def lottery_post
    lottery = Lottery.new @conference
    lottery.run
    # enrollment phase is now over
    @conference.status = Conference::REGISTRATION
    render :text => 'Lottery was run successfully.'
  end
  
  # reset lottery
  def lottery_reset_post
    lottery = Lottery.new @conference
    lottery.reset
    @conference.status = Conference::ENROLLMENT
    render :text => 'Lottery was reset.'
  end
  
  # export assignments
  def export
    require 'fastercsv'
    @assignments = Assignment.find :all, 
      :joins => 'inner join enrollments on enrollments.id = assignments.enrollment_id', 
      :conditions => 'enrollments.conference_id = %i' % @conference.id
    @csv = FasterCSV.generate(:col_sep => ',') do |csv|
      csv << @assignments.first.attributes.keys
      @assignments.each { |a| csv << a.attributes.values }
    end
  end
  
  # import assignments
  def import
  end
  
  # post import
  def import_post
    require 'fastercsv'
    raise 'need assignments' unless params[:assignments]
    Assignment.delete_all 'enrollment_id in (select id from enrollments where conference_id=%i)' % @conference.id
    FasterCSV.parse(params[:assignments], :headers => true, :col_sep => ',') do |row|
      Assignment.create row.to_hash
    end
    redirect_to :action => 'import_done'
  end
  
  # export tasks
  def export_tasks
    require 'fastercsv'
    @tasks = Task.find :all, :conditions => {:conference_id => @conference.id}, :order => 'day'
    @csv = FasterCSV.generate(:col_sep => ',') do |csv|
      csv << ['name', 'invisible', 'priority', 'description', 'day', 'start_time', 'end_time', 'hours', 'slots', 'location']
      @tasks.each do |t|
        csv << [t.name, t.invisible, t.priority, t.description, t.day, t.start_time, t.end_time, t.hours, t.slots, t.location]
      end
    end
  end
  
  # import tasks
  def import_tasks
  end
  
  # import tasks
  def import_tasks_post
    require 'fastercsv'
    raise 'need tasks' unless params[:tasks]
    FasterCSV.parse(params[:tasks], :headers => true, :col_sep => ',') do |row|
      attributes = row.to_hash
      
      # remove the hours key (not working during initial create)
      hours = attributes.delete 'hours'
      
      # add conference id
      attributes['conference_id'] = @conference.id
      attributes['description'] ||= ''
      
      # create task
      task = Task.new attributes
      
      # set hours from formatted string
      if hours =~ /(\d+):(\d+)/
        hours = $1.to_f + $2.to_f / 60

      # OR: set hours automatically if empty
      elsif !hours
        hours = (task.end_time.time - task.start_time.time) / 3600.0
        
      # OR: set hours from float
      else
        hours = hours.to_f
      end
      
      # set and save
      task.hours = hours
      task.save
      
    end
    redirect_to :action => 'import_tasks_done'
  end
  
  def dump
  end
  
  def dump_post
    c = ActiveRecord::Base.configurations[ENV['RAILS_ENV']]
    p = [c['database']]
    {'host' => '-h %s', 'username' => '-u %s', 'password' => '--password=%s'}.each do |k,v|
      p << v % c[k] if c[k]
    end
    p = p.join ' '
    @dump = `mysqldump #{p} | bzip2`
    send_data @dump, :type => 'application/x-bzip', :filename => 'sv.sql.bz2'
  end
  
  protected
  
  # id from @conference
  before_filter :before_post, :only => 'post'
  def before_post
    @id = @conference.id
  end

  # render POST method
  def render_post
    return render(:partial => 'conference', :locals => {:conference => @conference}) if request.xhr?
    redirect_to :action => :index
  end

  # must be admin to use this controller
  before_filter :require_admin, :except => 'index'
  def require_admin
    raise 'unauthorized' unless @admin_user.admin?
  end

end
