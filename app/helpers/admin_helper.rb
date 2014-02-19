module AdminHelper
  
  # select hours
  def select_hours(record, key, html_options = {})
    name = record.class.name.downcase.dasherize
    value = record.send(key)
    html_options['name'] = '%s[%s]' % [name, key]
    html_options['id'] = '%s_%s' % [name, key]
    options = ''
    0.upto(23) do |i|
      options_html = { :value => i }
      options_html[:selected] = 'selected' if i == value
      options += content_tag :option, (i < 10 ? '0%i' : '%i') % i, options_html
    end
    content_tag :select, options, html_options
  end

  # select hours
  def select_minutes(record, key, html_options = {})
    name = record.class.name.downcase.dasherize
    value = record.send(key)
    html_options['name'] = '%s[%s]' % [name, key]
    html_options['id'] = '%s_%s' % [name, key]
    options = ''
    [0,15,30,45].each do |i|
      options_html = { :value => i }
      options_html[:selected] = 'selected' if i == value
      options += content_tag :option, (i < 10 ? '0%i' : '%i') % i, options_html
    end
    content_tag :select, options, html_options
  end
  
  # create a selectable link
  # adds 'selected' class to the link if selected is true
  def selectable_link_to(title, selected, url_options, html_options = {})
    append_class! html_options, 'selected' if selected
    link_to title, url_options, html_options
  end
  
  # general link to I10.Request.Update
  def link_to_update(title, target, url_options = {}, options = {})
    target = target ? "'%s'" % target : 'null'
    link_to_function title, "new I10.Request.Update(this,%s,'%s')" % [target, url_for(url_options)], options
  end
  
  # general link to I10.Request.Dialog
  def link_to_dialog(title, target, url_options = {}, options = {})
    target = target ? "'%s'" % target : 'null'
    link_to_function title, "new I10.Request.Dialog(this,%s,'%s')" % [target, url_for(url_options)], options
  end
  
  # draw a universal search input field with remote call
  def search_input(value, target, url_options = {}, options = {})
    options[:value] = value
    options[:class] ||= 'search_input'
    options[:onfocus] = "new SearchInput(this,'%s','%s')" % [target, url_for(url_options)]
    tag :input, options
  end
  
  # draw a user search input field with remote call
  def user_search_input(value, target, options = {})
    options[:value] = value
    options[:id] ||='search_input_%s' % options[:target]
    options[:class] ||= 'search_input'
    options[:onfocus] = "new UserSearchInput(this,'%s')" % target
    tag :input, options
  end
  
  # draw an active input field that calls a post on change
  def active_input(record, key, url_options = {}, options = {})
    url_options[:id] = record.id
    record_name = record.class.name.downcase
    options[:onfocus] = "new I10.Request.Input(this,'%s','%s[%s]')" % [url_for(url_options), record_name, key]
    options[:value] = record.send(key)
    tag :input, options
  end
  
  # create a link to toggle the order
  def link_to_toggle_order(title, key, order)
    sort_key = key.to_s
    sort_key += ' desc' if order.to_s.starts_with?(key) and !order.ends_with?('desc')
    link_to title, :order => sort_key
  end

  # display an error box if an error is set
  def error_box(error)
    return unless error
    content_tag :div, error.to_s, :id => 'error'
  end
  
  # display all validation errors
  def validation_box(record)
    return if record.errors.empty?
    message = 'Validation error:<br/><ul>'
    record.errors.each_full { |e| message += content_tag :li, e }
    message += '</ul>'
    error_box message
  end

  # display an error box if an error is set
  def notice_box(notice)
    return unless notice
    content_tag :div, notice, :id => 'notice'
  end
  
  # make options for a select item
  def select_options(options, selected = nil)
    r = ''
    options.each do |k,v|
      opt = {:value => k}
      opt[:selected] = 'selected' if k == selected
      r += content_tag :option, v, opt
    end
    r
  end
  
  # what status options can we select?
  def status_options
    options = Status::STATUS
    options
  end
  
  # append a css class name to an html_options hash
  def append_class!(options, class_name)
    options.symbolize_keys!
    if options[:class]
      options[:class] += ' %s' % class_name
    else
      options[:class] = class_name
    end
  end
  
  # switch keys and values in a hash
  def switch_keys_and_values(hash)
    r = {}
    hash.each { |k,v| r[v] = k }
    r
  end
end
