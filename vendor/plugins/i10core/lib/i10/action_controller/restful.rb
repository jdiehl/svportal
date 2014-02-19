# Overrides the action_name method of ActionController::Base to allow better
# separation of retrieving and manipulating actions.
# 
# == RESTful actions in Rails
# 
# To initiate a RESTful call in Rails you may use the link_to_remote helper or
# create a form. In both cases, the method is chosen by defining the :method
# key of the options hash.
# 
# In classic rails, the request for a custom method is caught by the same
# action handler as a default GET method. This plugin changes that behavior
# by relaying the request to an action handler that is composed of both the
# action name and the method name:
# 
# 1. ACTION_METHOD (e.g. edit_post)
# 2. METHOD (e.g. post)
# 3. ACTION (e.g. edit)
# 
# == Relaying Example
# 
# In your controller you have the following methods defined:
#   def index
#   def edit
#   def edit_post
#   def delete
# 
# * a GET request to index will be relayed to index
# * a POST request to index will be relayed to index
# * a POST request to edit will be relayed to edit_post
# * a DELETE request to edit will be relayed to delete
# 
# == Example
# 
# The following controller makes use of RESTful relaying to implement a simple
# user management system with an edit action that uses a POST form to update
# user records and a DELETE Ajax call to remove users.
# 
#   class MyController < ActionController::Base
#     # show overview of users
#     def index
#       @users = User.find :all
#     end
# 
#     # show edit form for a user, include ajax link to DELETE method
#     def edit
#       @user = User.find params[:id]
#     end
#     
#     # process form submission
#     def edit_post
#       @user = User.update params[:id], params[:user]
#     end
#     
#     # delete user
#     def delete
#       User.delete params[:id]
#     end
#   end
module I10::ActionController::Restful

  # on including
  def self.included(base) # :nodoc:
    base.class_eval do
      
      # retrieve the restful action name
      def action_name # :nodoc:
        return @restful_action_name if @restful_action_name
        
        method = request.method
        if method != :get
          action = '%s_%s' % [@action_name, method]
          action = method.to_s unless self.class.action_methods.include? action
          action = @action_name unless self.class.action_methods.include? action
        else
          action = @action_name
        end
        @restful_action_name = action
      end
      
    end
    
  end
end