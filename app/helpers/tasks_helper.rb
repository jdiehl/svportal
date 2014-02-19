module TasksHelper
  # renders buttons that look like tabs
  def link_to_day(day, selected, options = {})
    options[:class] = 'inactive' unless day.allow_bidding?
    options[:class] = (options[:class] ? options[:class]+' %s' : '%s') % 'selected' if selected
    link_to day, {:action => 'index', :day => day.id}, options
  end
  
  # general link to I10.Request.Reload
  def button_to_reload(title, url_options = {}, options = {})
    content_tag :input, options, {:type => 'button', :value => title, :onclick => "new I10.Request.Reload(this,'%s')" % url_for(url_options)}
  end  
  
  # render link to create a bid
  def bid_update(title, task, preference)
    link_to_function title, 
      'new UpdateBid(this,%i,%i)' % [task.id, preference],
      :title => 'Place bid with %s preference' % Bid.preference_name(preference)
  end
  
  # renders link to delete a bid
  def bid_remove(title, task)
    link_to_function title, 
      'new UpdateBid(this,%i)' % task.id,
      :title => 'Remove bid'
  end
  
  # status code for bids table
  def status_class(task)
    return 'a' if task.assignment_status
    return 'f' if task.bid_status.to_i == Bid::FULL or task.full?
    return 'c' if task.bid_status.to_i == Bid::CONFLICT
    return 'p%i' % task.bid_preference.to_i if task.bid_preference
    'p'
  end

end
