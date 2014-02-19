# Adds several useful methods to the ActionController class
# 
# == Exception Handling
# 
# This plugin replaced the error representation for XHR (AJAX) requests with a
# more readable representation without HTML code.
# 
module I10::ActionController::ConvenienceMethods
  
  # on include
  def self.included(base) #:nodoc:
    base.class_eval do
      
      alias rescue_action_without_xhr rescue_action
      # override rescue_action
      def rescue_action(exception) #:nodoc:
        return rescue_action_without_xhr(exception) unless request.xhr?
        text = local_request? ? "%s in...\n%s" % [exception.message, exception.backtrace.join("\n")] : '500 Internal Error'
        render :status => 500, :text => text
      end
      
    end
  end

  # Store parameters in the session to redirect back to them later.
  #  
  # ==== Parameters
  # 
  # * parameters: override params
  # 
  def store_back_params(parameters = nil)
    session[:redirect_params] = options ? options : params
  end
  
  # Redirect back to the stored arameters or to the given options if none are
  # stored.
  # 
  # ==== Parameters
  # 
  # * url_options: params to use when no params are stored
  # 
  def redirect_back_or_to(url_options)
    if session[:redirect_params]
      options = session[:redirect_params]
      session[:redirect_params] = nil
    end
    redirect_to options
  end
  
end