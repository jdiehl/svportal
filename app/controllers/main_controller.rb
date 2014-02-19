class MainController < ApplicationController
  def index
    redirect_to :controller => 'news', :conference_name => @conference_name
  end

  # choose the conference to work with
  def select_conference
    if params[:conference]
      session[:conference] = params[:conference]
      redirect_back_or_to DEFAULT_ACTION
    else
      @conferences = Conference.find_active
      render :layout => false
    end
  end
  
  # perform login
  def login_post
    raise 'need login' unless params[:login]    

    # authenticate and store user
    if user = User.authenticate(params[:login][:email], params[:login][:password])
      login_as user
      render :partial => 'layouts/nav'
    else
      @login = User.new params[:login]
      render :status => 401, :text => 'Unknown email address or wrong password'
    end
  end
  
  # perform logout
  def logout
    session[:uid] = nil
    redirect_to :controller => 'news'
  end
  
  # maintenance
  def maintenance
    render :layout => false
  end
  
  protected
  
  # login as this user
  def login_as(user)
    @user = user
    @enroll = @user.enrollment_for_conference @conference
    session[:uid] = @user.id
  end

end
