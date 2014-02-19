class TshirtSize < ActiveRecord::Base

  # return all sizes in order
  def self.all
    @@sizes ||= find :all, :order => '`order`'
  end

  # renders string representation (required for e.g. select boxes)
  def to_s
    name
  end
end
