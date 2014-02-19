module I10::ActiveRecord::Errors

  # Convert the errors of an ActiveRecord to a Hash
  def to_hash
    @errors
  end
  
end