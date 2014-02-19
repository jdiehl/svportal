class ShortTime
  attr_accessor :time

  # import from wrapable
  def self.in(time)
    new time
  end
  
  # output to wrappable
  def out
    to_s
  end
  
  # constructor
  def initialize(time = nil)
    time = '8:00' unless time
    time = time.time if time.is_a?(ShortTime)
    time = Time.parse(time) unless time.is_a?(Time)
    self.time = time
  end
  
  def <=(otherTime)
    time <= otherTime.time
  end
  
  # string representation
  def to_s
    time.strftime '%H:%M'
  end
  
  # accessors
  def hours
    time.hour
  end
  def hours=(v)
    self.time = Time.parse('%i:%i' % [v.to_i, minutes])
  end
  
  def minutes
    time.min
  end
  def minutes=(v)
    self.time = Time.parse('%i:%i' % [hours, v.to_i])
  end
end
