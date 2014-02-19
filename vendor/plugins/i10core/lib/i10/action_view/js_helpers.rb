# Defines helper methods to use the i10 JavaScript classes.
# 
module I10::ActionView::JsHelpers
  
  # Create a link to a dialog.
  # 
  # A dialog is a div layer, which is filled with the response from an xhr call
  # to the given url. The layer is reused for subsequent calls.
  # 
  # Uses the I10.Dialog JavaScript class
  # 
  def link_to_dialog(title, url_options, html_options = {})
    link_to_function title, "new I10.Dialog(this,'%s')" % url_for(url_options), html_options
  end
  
  # Create an i10 (xhr) form.
  # 
  # The i10_form_for method works exactly like the form_for method, with the
  # exception that it uses the I10.FormSubmitter class to submit and validate
  # the form via xhr.
  # 
  # If the validation fails, the controller should respond with a status 400
  # response and an json object representing the validation errors. The object
  # should be a hash with the keys representing the violated field names and
  # the values the error messages as string or array of strings. The given error
  # messages are then displayed alongside the according fields.
  # 
  # If the validation succeeds the page is redirected to the given url.
  def i10_form_for(name, url_options = nil, options = {}, &block)
    url = url_options ? ",'%s'" % url_for(url_options) : ''
    options[:html] ||= {}
    options[:html][:onsubmit] = "new I10.FormSubmitter(this,'%s'%s); return false;" % [name, url]
    form_for name, nil, options, &block
  end
  
end