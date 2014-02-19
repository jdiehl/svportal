module I10::ActiveRecord
end

require 'i10/active_record/convenience_methods'
require 'i10/active_record/cute_indexes'
require 'i10/active_record/errors'
require 'i10/active_record/migration_extension'
require 'i10/active_record/order_by'
require 'i10/active_record/searchable'
require 'i10/active_record/tagable'
require 'i10/active_record/wrapable'

# ActiveRecord Extensions
ActiveRecord::Base.class_eval do
  extend I10::ActiveRecord::AuthenticatedUser
  include I10::ActiveRecord::ConvenienceMethods
  extend I10::ActiveRecord::OrderBy
  extend I10::ActiveRecord::Searchable
  extend I10::ActiveRecord::Tagable
  extend I10::ActiveRecord::Wrapable
end

# ActiveRecord TableDefinition
ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  include I10::ActiveRecord::CuteIndexes
end

# ActiveRecord Errors
ActiveRecord::Errors.class_eval do
  include I10::ActiveRecord::Errors
end

# ActiveRecord Migration Extensions
ActiveRecord::Migration.class_eval do
  include I10::ActiveRecord::MigrationExtension
end
