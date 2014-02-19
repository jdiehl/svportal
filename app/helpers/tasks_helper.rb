module TasksHelper  
  # general link to I10.Request.Reload
  def button_to_reload(title, url_options = {}, options = {})
    content_tag :input, options, {:type => 'button', :value => title, :onclick => "new I10.Request.Reload(this,'%s')" % url_for(url_options)}
  end  
  
  # render link to create a bid
  def bid_update(title, tasktype, preference)
    link_to_function title, 
      'new UpdateBid(this,%i,%i)' % [tasktype.id, preference],
      :title => 'Place bid with %s preference' % Bid.preference_name(preference)
  end
  
  # renders link to delete a bid
  def bid_remove(title, tasktype)
    link_to_function title, 
      'new UpdateBid(this,%i)' % tasktype.id,
      :title => 'Remove bid'
  end
  
  # status code for bids table
  def status_class(tasktype)
    return 'a' if tasktype.assignment_status
    return 'f' if tasktype.bid_status.to_i == Bid::FULL or tasktype.full?
    return 'c' if tasktype.bid_status.to_i == Bid::CONFLICT
    return 'p%i' % tasktype.bid_preference.to_i if tasktype.bid_preference
    ''
  end

end
