# Extends the Time class with the to_human method, which represents a time in
# the most appropriate human-readable form:
# 
# == Examples
# 
# Assuming it is 7:58pm:
# 
#   Time.now.to_human           -> '1 minute ago'
#   2.minutes.ago.to_human      -> '2 minutes ago'
#   6.minutes.ago.to_human      -> '5 minutes ago'
#   16.minutes.ago.to_human     -> '15 minutes ago'
#   57.minutes.ago.to_human     -> '7pm'
#   70.minutes.ago.to_human     -> '7pm'
#   Time.parse('7:30').to_human -> '7am'
#   20.hours.ago                -> 'yesterday'
# 
module I10::ActiveSupport::HumanTime
  
  # Converts the time to a human-readable format
  def to_human
    now = Time.now
    dif = (now - self).round / 60
    case
    when dif <= 1 # within the minute
      '1 minute ago'
    when dif <= 5 # within 5 minutes
      '%i minutes ago' % dif
    when dif < 53 # within the hour
      '%i minutes ago' % ((dif / 5.0).round * 5)
    when day == now.day && dif < 86400 # same day
      h = hour
      h += 1 if min > 30
      ampm = (h >= 12 and h < 24) ? 'pm' : 'am'
      h -= 12 if h > 12
      h = 12 if h == 0
      '%i%s' % [h, ampm]
    else
      to_date.to_human
    end
  end

end