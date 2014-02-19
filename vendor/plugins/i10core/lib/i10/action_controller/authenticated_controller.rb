module I10::ActionController::AuthenticatedController
  
  # make the controller authenticating
  def authenticated(class_name)
    class_name = Object.const_get class_name unless class_name == ActiveRecord::Base
    @_authenticated_class = class_name
    
    class_eval do
      
    end
  end
  
end