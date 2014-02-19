class UserController < ApplicationController
  before_filter :require_login, :except => [:password_request, :password_request_post, :password_request_done, :password_reset, :password_reset_post, :signup, :signup_post, :signup_done]

  include I10::ActionController::Restful
  controls_active_record :user
  
  # edit user profile
  def profile
  end
  
  # confirmation
  def profile_done
  end
  
  # password reset request
  def password_request
  end
  
  # sent mail to specified email-adr with new ticket (ticket required to reset password)
  def password_request_post
    raise 'need email' unless params[:email]
    
    # check if user exists with specified email address
    if user = User.find_by_email(params[:email])
      url = {:host => request.host, :port => request.port, :conference_name => params['conference_name'], :controller => 'user', :action => 'password_reset', :only_path => false}
      user.password_request @conference, url
      return redirect_to(:action => 'password_request_done')
    end

    @error = 'No user found for the email provided'
    render :action => 'password_request'
  end
  
  # show: password recovery successful (new action to prevent resend of mail notification)
  def password_request_done
  end
  
  # renders a form to enter a new password, and the authorisation ticket
  def password_reset
    raise 'need token' unless params[:token]
    raise 'invalid token' unless @user = User.authenticate_with_recovery_token(params[:token])
    @enroll = @user.enrollment_for_conference @conference
  end
  
  # sets new password if ticket authorisation succeeds
  def password_reset_post
    raise 'need token' unless params[:token]
    return render(:status => 401, :text => 'Unauthorized') unless @user = User.authenticate_with_recovery_token(params[:token])
    post
    session[:uid] = @user.id if @user.valid?
  end
  
  def password_reset_done
  end
    
  # edit user password
  def password
    unless @user.valid?
      flash[:notice] = 'Please complete your profile before changing your password.'
      return redirect_to(:action => 'profile')
    end
  end
  
  # confirmation
  def password_done
  end
  
  # show register form for signup
  def signup
    @user = User.new
  end
  
  # create user
  def signup_post
    post
    session[:uid] = @user.id if @user.valid?
  end
  
  # show: signup was successful
  def signup_done
  end
  
  # ActiveObject needs this action to render correctly 
  def options
    values = active_record_class.send '%s_options' % params[:k]
    render :json => values
  end  
  
  protected
  
  before_filter :before_post, :only => 'post'
  def before_post
    @id = @user.id if @user
  end
  
  # after updating the users profile or sign up
  def render_post
    if @user.valid?
      return redirect_to(:controller => 'enrollment', :action => 'enroll') if params[:action] == 'signup'
      return redirect_to(:action => '%s_done' % params[:action])
    end
    render params
  end

end
