# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # start observing a variable
  def observe(initial_value = nil)
    @_observed = initial_value
  end

  # determine whether the variable has changed
  def has_changed?(new_value)
    @_observed = new_value if @_observed != new_value
  end
  
  # human date
  def human_date(date, format = '%B %d, %Y')
    date.strftime format
  end
  
  # markup text with RedCloth
  def markup text
    RedCloth.new(text).to_html
  end

  # genereates a link that renders a popup
  def tooltip(tag, title, text, options = {})
    if text
      options[:onmouseover] = "new I10.Tooltip(event,this,'%s')" % escape_javascript(text)
      options[:class] = options[:class] ? '%s tooltip' % options[:class] : 'tooltip'
    end
    content_tag tag, title, options
  end

end
