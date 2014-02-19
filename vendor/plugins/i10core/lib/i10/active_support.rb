module I10::ActiveSupport
end

require 'i10/active_support/array_extension'
require 'i10/active_support/hash_extension'
require 'i10/active_support/human_time'
require 'i10/active_support/human_date'

# Array extensions
Array.class_eval do
  include I10::ActiveSupport::ArrayExtension
end

# Hash extensions
Hash.class_eval do
  include I10::ActiveSupport::HashExtension
end

# Date Extensions
Date.class_eval do
  include I10::ActiveSupport::HumanDate
end

# Time Extensions
Time.class_eval do
  include I10::ActiveSupport::HumanTime
end

