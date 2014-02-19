# Extends the Date class with the to_human method, which represents a date in
# the most appropriate human-readable form:
# 
# == Examples
# 
# Assuming today is Saturday, April 19th 2008:
# 
#   Date.today.to_human  -> 'today'
#   1.day.ago.to_human   -> 'yesterday'
#   2.days.ago.to_human  -> 'Thursday'
#   10.days.ago.to_human -> 'April 9'
#   1.year.ago.to_human  -> 'April 19, 2008'
# 
module I10::ActiveSupport::HumanDate
  
  # Converts the date to a human-readable format
  def to_human
    today = Date.today
    dif = (today - self).to_i
    case
    when dif == 0 # same day
      'today'
    when dif == 1 # yesterday
      'yesterday'
    when dif < 7 # within the last 6 days
      strftime '%A'
    when year == today.year # same year
      strftime '%B %d'
    else
      strftime '%B %d, %Y'
    end
  end

end