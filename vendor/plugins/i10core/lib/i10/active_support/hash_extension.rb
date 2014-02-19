# Extends the Hash class with several useful methods
# 
module I10::ActiveSupport::HashExtension
  
  # Collect the keys and values of a Hash by iterating through the Hash. Each
  # step should return an array of the form [key, value]
  # 
  # ==== Example
  # 
  # Swap keys and values in a Hash:
  #   hash.collect_h { |k,v| [v,k] }
  # 
  def collect_h
    result = {}
    each do |key, value|
      key, value = yield key, value
      result[key] = value
    end
    result
  end
  
  # Swap keys and values
  # 
  #   { :a => 1, :b => 2 }.reverse
  #   => { 1 => :a, 2 => :b }
  def reverse
    collect_h { |k,v| [v,k] }
  end
  
end