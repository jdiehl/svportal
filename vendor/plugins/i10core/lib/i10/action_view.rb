module I10::ActionView
end

require 'i10/action_view/cute_form_builder'
require 'i10/action_view/js_helpers'

# ActionView Extensions
ActionView::Base.class_eval do
  self.default_form_builder = I10::ActionView::CuteFormBuilder
  self.field_error_proc = Proc.new { |html_tag, instance| html_tag }
  include I10::ActionView::JsHelpers
end
