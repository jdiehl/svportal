class Hours
  attr_accessor :hours, :minutes
  
  # input for wrapable
  def self.in(time)
    new(time) rescue time
  end

  # output for wrapable
  def out
    to_f
  end

  # constructor
  def initialize(time)
    # input is time
    if time.is_a?(Time)
      self.hours = time.hours
      self.minutes = time.minutes
    # input is numeric
    elsif time.is_a?(Numeric)
      self.hours = time.floor
      self.minutes = ((time - self.hours) * 60).round
    elsif /(\d+):(\d+)/ =~ time.to_s
      self.hours = $1.to_i
      self.minutes = $2.to_i
    elsif /(\d+([.,]\d+)?)/ =~ time.to_s
        time = $1.gsub(',', '.').to_f
        self.hours = time.floor
        self.minutes = ((time - self.hours) * 60).round
    else
      raise 'invalid time %s' % time.to_s
    end
  end

  # string representation
  def to_s
    '%s:%s' % [hours, format(minutes)]
  end

  # formatting (2 digits)
  def format(s)
    s = s.to_s
    s.length > 1 ? s : '0'+s
  end

  # float conversion
  def to_f
    hours.to_f + minutes.to_f/60
  end

end
