class Admin::MailsController < AdminController
  MAX_EMAILS_PER_DELIVERY = 50
  
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
    deliver
  end
  
  # deliver the mails
  def deliver
    raise 'need id' unless @mail or params[:id]
    @mail ||= Mail.find params[:id]
    @offset = params[:offset].to_i
    @offset ||= 0
    @mail.deliver_part @offset, MAX_EMAILS_PER_DELIVERY
    if @mail.count > @offset + MAX_EMAILS_PER_DELIVERY
#     render :text => url_for(:action => 'deliver', :id => @mail.id, :offset => @offset + MAX_EMAILS_PER_DELIVERY)
      redirect_to :action => 'deliver', :id => @mail.id, :offset => @offset + MAX_EMAILS_PER_DELIVERY
    else
#      render :text => 'index'
      redirect_to :action => 'index'
    end
  end
  
  def submit_done
    redirect_to :action => 'index'
  end
  
  protected
  
  # after editing
  def render_post
    return redirect_to(:action => 'index') if @mail.errors.empty?
    render :action => 'submit'
  end
end
