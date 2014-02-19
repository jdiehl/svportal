# Enables template inheritance within ActionControllers.
# 
# ==== Controller Inheritance
# 
# Action Controllers can be subclassed to allow grouping of controllers in the
# routes and reusing functionality. Rails already does the latter by
# automatically subclassing all generated controllers from
# ApplicationController.
# 
# Templates, however, do not follow this inheritance scheme. This plugin changes
# the ActionController class to implement inheritable templates. If a controller
# is subclassed from another controller and no template is defined for a given
# method, the super-controller is checked for the template. Finally, if no
# template is found, the plugin trys to load a rescue template, located in an
# optional rescue/ folder in the views folder.
# 
# ==== Example
# 
# There are two controllers:
# 
#   class AController < ActionController::Base
#   class AController < BController
# 
# Further, there are four templates:
# 
#   app/views/a/item.rhtml
#   app/views/b/index.rhtml
#   app/views/b/item.rhtml
#   app/views/rescue/error.rhtml
# 
# * when calling method index on controller A, the template index of controller
# B is displayed.
# * when calling method item on controller A, the template item of controller A
# is displayed.
# * when calling method error on controller A or B,the template error in the
# rescue folder is displayed.
# 
# ==== Restrictions
# 
# This plugin does not affect partials!
# 
module I10::ActionController::TemplateInheritance

  # on inclusion
  def self.included(base) # :nodoc:
    base.class_eval do
      
      # define template_exists method that has been taken out of rails since 2.2.2
      def template_exists?(path)
        self.view_paths.find_template(path, response.template.template_format)
      rescue ActionView::MissingTemplate
        false
      end
    
      # override method that retrieves the template name to allow template 
      # inheritance
      def default_template_name(action_name = self.action_name) # :nodoc:
        
        # from the orginal method
        if action_name
          action_name = action_name.to_s
          if action_name.include?('/') && template_path_includes_controller?(action_name)
            action_name = strip_out_controller(action_name)
          end
        end
        
        # recursively go through controller inheritance
        current = self.class
        while current != ActionController::Base
        
          # search for the template in this controller
          template_file = '%s/%s' % [current.controller_path, action_name]
          return template_file if template_exists? template_file
          
          # go to the next (super-) controller
          current = current.superclass
        end
        
        # fall back to rescue if no template found
        template_file = 'rescue/%s' % action_name
        return template_file if template_exists? template_file
        
        # form the original method
        "#{self.class.controller_path}/#{action_name}"
      end
    end
  end

end
