module Admin::TasksHelper
  
  # prints a select tag for the days of a conference
  def select_day(days, selected_day = nil, html_options = {})
    
    # construct day options
    select_options = []
    days.each do |day|
      title = day.human_date
      option = { :value => day.id }
      option[:selected] = 'selected' if day.id == selected_day
      select_options << content_tag(:option, title, option)
    end
    # draws a <select> tag
    content_tag :select, select_options, html_options
  end
  
  # create a link to display a list of conference tasks for a date
  def link_to_day(day, html_options = {})
    options = { :update => 'tasks', :url => {:action => 'list', :day => day.id}, :method => 'get' }
    title = day.human_date
    link_to_remote title, options, html_options
  end
    
end
