# extends an ActionController with methods for RESTful ActiveRecord manipulation
# 
# requires I10::Restful
# 
# == RESTful ActiveRecord Manipulation
# 
# RESTful ActiveRecord manipulation makes use of custom HTTP request methods to
# indicate manipulation of data objects. The most basic methods are:
# 
# * post: create an object
# * put: change an object
# * delete: remove an object
# 
# This plugin provides a generic implementation for these three methods. Note
# that POST requests are forwarded to PUT if an id is given.
# 
# To initiate a RESTful call in Rails you may use the link_to_remote helper or
# create a form. In both cases, the method is chosen by defining the :method
# key of the options hash.
# 
# == Rendering
# 
# To allow custom render actions after manipulating an object, the 
# render_restful method is called. It first checks, whether the controller
# implements one of the following methods and calls it:
# 
# 1. render_ACTION_METHOD
# 2. render_METHOD
# 3. render_ACTION
# 
# By implementing one of these methods, a custom page can be rendered after
# the generic manipulation of the ActiveRecord. The record is stored in an
# instance variable named after the class name. If no method is found, a
# default response is rendered.
# 
# For XHR (Ajax) requests:
# * Valid Manipulation: render empty page with status 200
# * Invalid Manipulation: render JSON object representing the errors with status 400
# 
# For normal requests:
# * Valid Manipulation: redirect to ACTION_done
# * Invalid Manipulation: render ACTION
# 
# == Example
# 
# To use the RestfulController, you need to specify which ActiveRecord class
# should be controlled in your controller. We also define a custom render
# method for post requests, which renders our form
# 
#   class MyController < ActionController::Base
#     # enable controlling of User object
#     controls_active_record :user
# 
#     # edit a user
#     def edit
#       @user = User.find params[:id]
#     end
# 
#     # after editing
#     # we can access the record through the variable @user
#     def render_edit
#       return render(:action => 'done') if @user.errors.empty?
#       render :action => 'edit
#     end
# 
#   end
# 
# In the edit view, a basic form is created to allow the user to change the
# record.
# 
#   <%= form_for :user do |f| %>
#     <%= f.text_field :name %>
#     <%= f.text_field :email %>
#     <%= f.submit %>
#   <% end %>
# 
# This is already sufficient to implement a basic manipulation website for the
# User model.
# 
# == The Magic
# 
# The RestfulController plugin relys on several conventions:
# 
# * params[:id] represents the id of the object to be manipulated.
# * The ActiveRecord is read and written to the instance variable named after the ActiveRecord class. By assigning this instance variable before calling a RESTful method, params[:id] can be overridden.
# * the updated attributes are passed as a hash in params[CLASS_NAME]
# * the RestfulController defines (and overwrites) the methods post, put, and delete, which are called for the appropriate requests by the I10::Restful plugin. To add code before or after the RESTful manipulation, define a method called ACTION_METHOD (e.g. edit_post) and call post in it.
# 
# == Integration with I10.FormSubmitter
# 
# This plugin was written to integrate neatly with the I10.FormSubmitter
# JavaScript class, which uses AJAX calls to submit and validate web forms.
# See I10::ActionView::JsHelpers for helper methods to use this functionality.
# 
module I10::ActionController::RestfulController
  DONE_ACTION = '%s_done'
  
  # enable the RestfulController for an ActionController
  # 
  # ==== Parameters
  # 
  # * class_name: the name of the ActiveRecord class to be controlled. Only ony class can be controller per controller
  # 
  def controls_active_record(class_name)
    class_eval <<-EOV
      def active_record_class
        #{class_name.to_s.classify}
      end
      def active_record_name
        :#{class_name.to_s}
      end
    EOV
    
    # extend
    class_eval do
      
      # post method call: create a new record
      # 
      # ==== Expected Parameters
      # 
      # * params[CLASS_NAME]: the updated attributes
      # 
      # If params[:id] is given, the request is forwarded to put
      def post
        return put if params[:id] or instance_variable_get('@%s' % active_record_name)
        raise 'need attributes' unless attributes = params[active_record_name]
        record = active_record_class.create attributes
        instance_variable_set '@%s' % active_record_name, record
        render_restful
      end
      
      # put method call: update an existing record
      # 
      # ==== Expected Parameters
      # 
      # * params[:id]: the id of the record to be updated
      # * params[CLASS_NAME]: the updated attributes
      def put
        raise 'need attributes' unless attributes = params[active_record_name]
        case
        when record = instance_variable_get('@%s' % active_record_name)
          attributes.each { |k,v| record.send '%s=' % k, v }
          record.save
        when id = params[:id]
          record = active_record_class.update id, attributes
        else
          raise 'need id'
        end
        instance_variable_set '@%s' % active_record_name, record
        render_restful
      end

      # delete method call: remove a record
      # 
      # ==== Expected Parameters
      # 
      # * params[:id]: the id of the record to be removed
      def delete
        case
        when record = instance_variable_get('@%s' % active_record_name)
        when id = params[:id]
          record = active_record_class.find id
        when attributes = params[active_record_name]
          record = active_record_class.find :first, :conditions => attributes
        else
          raise 'need id or attributes'
        end
        record.destroy
        instance_variable_set '@%s' % active_record_name, record
        render_restful
      end
      
      # allow custom rendering
      def render_restful # :nodoc:
        action = params[:action]
        ['render_%s_%s' % [action, request.method], 'render_%s' % request.method, 'render_%s' % action].each do |a|
          return send(a) if respond_to? a
        end
        record = instance_variable_get '@%s' % active_record_name
        if request.xhr?
          return render(:status => 400, :json => record.errors.to_hash) unless record.errors.empty?
          render :nothing => true
        else
          return redirect_to(:action => DONE_ACTION % action) if record.errors.empty?
          render :action => action
        end
      end

    end
  end
  
end