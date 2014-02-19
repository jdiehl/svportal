module TimeslotsHelper
  # general link to I10.Request.Reload
  def button_to_reload(title, url_options = {}, options = {})
    content_tag :input, options, {:type => 'button', :value => title, :class => 'freeall', :onclick => "new I10.Request.Reload(this,'%s')" % url_for(url_options)}
  end  
  
  # render link to save availability
  def avail_update(title, timeslot, day, td_id)
    link_to_function title, 
      'new UpdateAvailability(this,%i,\'%s\',\'%s\')' % [timeslot.id, day, td_id],
      { :id => 'a' + td_id }
  end
end
