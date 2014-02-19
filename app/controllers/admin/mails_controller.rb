class Admin::MailsController < AdminController
  include I10::ActionController::Restful
  controls_active_record :mail

  # list mail history
  def index
    @order = update_session :mails_order, params[:order], 'created_at desc'
    @order = 'ISNULL(event),%s' % @order if /event/ =~ @order
    options = {
        :conditions => { :conference_id => @conference.id }, 
        :order => @order
    }
    @mails = Mail.find :all, options
    @email_queue_length = Email.count
  end
  
  # view mail
  def view
    raise 'need id' unless params[:id]
    @mail = Mail.find params[:id]
  end

  # send mail form
  def submit
    # template
    if params[:template]
      template = Mail.find(params[:template])
      @mail = template.clone
    else
      @mail = Mail.new :conference_id => @conference.id
    end
  end

  # send mail
  def submit_post
    raise 'need mail object' unless params[:mail]
    params[:mail][:conference_id] = @conference.id
    @mail = Mail.create params[:mail]
    return render(:action => 'submit') unless @mail.errors.empty?
    @mail.deliver
    redirect_to :action => 'index'
  end
  
  protected
  
  # after editing
  def render_post
    return redirect_to(:action => 'index') if @mail.errors.empty?
    render :action => 'submit'
  end
end
