# Allows "cute" forms.
# 
# == Usage
# 
# Cute forms accept the names of the columns to present an input column for
# the columns. The type of the input column is derived from the columns name and
# column type:
# 
# === Column Naming Conventions
# * References are represented with a select column, listing the records from the referenced table.
# * Columns starting with 'password' are represented by an input column with type password.
# * Columns named 'gender' are represented by a select column with two options: 'f' => 'female' and 'm' => 'male'
# 
# === Column Type Conversion
# * Columns of type TEXT are represented by a text area
# * Columns of type BOOLEAN are represented by an input column of type checkbox
# * Columns of type DATE are represented by three select columns for day, month, and year
# * everything else is represented by text input columns
# 
# == Validation Errors
# 
# For fields with validation errors, the css class of the input field is set
# to error and a div layer with css class errorDescription containing the 
# description of the error is added.
# 
# This behavior can be suppressed by adding the following key to the options Hash
#   :ignore_errors => true
# 
# Note that this plugin overrides the standard Rails behavior to add a new div
# layer around all fields with errors.
# 
# == Example
# 
# Assuming the User model has the columns name, email, password, gender, and
# group_id with group_id referencing to the groups table, a form to edit a User
# object can be realized as following:
# 
#   <% form_for :user do |f| %>
#     <%= f.name 'Name:' %>
#     <%= f.email 'Email:' %>
#     <%= f.password 'Password:' %>
#     <%= f.gender 'Gender:' %>
#     <%= f.group 'Group:' %>
#     <%= f.submit %>
#   <% end %>
# 
# The resulting form will be as following:
# 
#   <form action="/" method="post">
# 
#     <label for="user_name">Name:</label>
#     <input id="user_name" name="user[name]" type="text" />
# 
#     <label for="user_email">Email:</label>
#     <input id="user_email" name="user[email]" type="text" />
# 
#     <label for="user_password">Password:</label>
#     <input id="user_password" name="user[password]" type="password" />
# 
#     <label for="user_gender">Gender:</label>
#     <select id="user_gender" name="user[gender]">
#       <option value="" selected="selected">Please select...</option>
#       <option value="f">female</option>
#       <option value="m">male</option>
#     <select>
# 
#     <label for="user_group">Gender:</label>
#     <select id="user_group" name="user[group]">
#       <option value="" selected="selected">Please select...</option>
#       <option value="1">Users</option>
#       <option value="2">Administrators</option>
#     <select>
# 
#     <input id="user_submit" name="commit" type="submit" value="Save changes" />
# 
#   <form>
# 
class I10::ActionView::CuteFormBuilder < ActionView::Helpers::FormBuilder
  ERROR_CLASS = 'error'
  ERROR_DESCRIPTION_CLASS = 'errorDescription'

  NO_SELECTION_OPTION = 'Please select...'

  GENDER_COLUMN_NAME = /^gender$/
  GENDER_OPTIONS = [['female', 'f'], ['male', 'm']]
  
  PASSWORD_COLUMN_NAME = /^password(_confirmation)?$/
  
  TYPE_HANDLER = {
    :string    => 'text_field', 
    :text      => 'text_area', 
    :integer   => 'text_field', 
    :float     => 'text_field', 
    :decimal   => 'text_field', 
    :date      => 'text_field',
    :datetime  => 'text_field', 
    :timestamp => 'text_field', 
    :time      => 'text_field', 
    :binary    => 'text_field', 
    :boolean   => 'check_box',
    :password  => 'password_field'
  }
  
  # Allow "cute" forms
  # 
  # == Parameters
  # 
  # * method: name of the method that was called
  # * label: (optional) label text for the input field
  # * options: (optional) HTML options hash
  # 
  # The options hash may include the special key :ignore_errors to suppress the
  # visualization of errors.
  def method_missing(column_name, label = nil, options = {})
    object_class = Object.const_get object_name.to_s.classify
    r = []
    
    # select from reflection for association
    if reflection = object_class.reflections[column_name]
      items = reflection.klass.all if reflection.klass.respond_to? :all
      items ||= reflection.klass.find :all
      column_name = reflection.association_foreign_key
      field_proc = Proc.new { select column_name, items, true, options }
    
      # see if there is a COLUMN_options method and use that for select options
      elsif object_class.respond_to? '%s_options' % column_name
        items = object_class.send('%s_options' % column_name)
        field_proc = Proc.new { select column_name, items, true, options }

    # special attribute: gender
    elsif GENDER_COLUMN_NAME =~ column_name.to_s
      field_proc = Proc.new { select column_name, GENDER_OPTIONS, true, options }
      
    # input type from column for real attribute
    else
      column_type = :password if PASSWORD_COLUMN_NAME =~ column_name.to_s
      column_type ||= object_class.columns_hash[column_name.to_s].type
      raise 'Unknown column type for `%s`' % column_name if column_type == NilClass
      input_type = TYPE_HANDLER[column_type.to_sym] or raise 'Unknown column type `%s`' % column_type
      field_proc = Proc.new { send input_type, column_name, options }
    end
    
    # see if we have errors
    if !options.delete(:ignore_errors) and object and errors = object.errors.on(column_name)
      options[:class] = options[:class] ? '%s %s' % [options[:class], ERROR_CLASS] : ERROR_CLASS
    end
    
    # label (must happen last since reflection might change the column name)
    r = []
    r << label(column_name, label) if label
    r << field_proc.call
    
    # errors
    if errors
      errors = [errors] if errors == String
      error_messages = errors.collect{ |e| '<li>%s %s</li>' % [column_name.to_s.humanize, e] }
      r << '<ul class="%s">%s</ul>' % [ERROR_DESCRIPTION_CLASS, error_messages.join('<br/>')]
    end
    
    r
  end

  # Create a select input from an Array or a Hash
  # 
  # ==== Parameters
  # 
  # * column_name: name of the column to create the select column for
  # * options: an array of values, [value, key] pairs, or ActiveRecord objects, or a hash mapping values to keys
  # * no_selection_option: a string representing the first option of the select field or true for the default text
  # 
  def select(column_name, select_options, no_selection_option = false, options = {})
    
    # initialize options hash
    select_array = []
    object_is_null = (!object or object.send(column_name).nil? or object.send(column_name) == '')
    if no_selection_option and (object_is_null or object.class.columns_hash[column_name.to_s].null)
      select_array << [no_selection_option === true ? NO_SELECTION_OPTION : no_selection_option, nil]
    end
    
    # convert array of active records to hash
    if select_options.is_a? Array and select_options.first.is_a? ActiveRecord::Base
      select_options.each { |o| select_array << [o.to_s, o.id] }
    elsif select_options.is_a? Hash
      select_options.each { |k,v| select_array << [k, v] }
    else
      select_array += select_options
    end
    
    super column_name, select_array, {}, options
  end
  
  def select_yesno(column_name, no_selection_option = false, options = {})
    select column_name, {'No' => 0, 'Yes' => 1}, no_selection_option, options
  end
  
  protected
  
  def object # :nodoc:
    @object || (@template.instance_variable_get("@#{@object_name}") rescue nil)
  end
  
end