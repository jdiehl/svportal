# Extends table definitions in ActiveRecord::Migrations with "cute" indexing.
# 
# == Usage
# 
# The definition of table columns is extended by several options, which can be
# provided using the options hash:
#   :index => true: create an index on the column
#   :unique => true: create a unique index on the column
# 
# Further ther references definition is extended to automatically add a foreign
# key to the column. Two additional options can be provided:
#   :ondelete => (RESTRICT|CASCADE|NULL|NONE): define the behavior for deleting the referenced row
#   :onupdate => (RESTRICT|CASCADE|NULL|NONE): define the behavior for changing the referenced row
# 
# == Example
# 
# This migration does exactly the same as the example in
# I10::ActiveRecord::MigrationExtension: A users table with an index on the
# name column, a unique index on the email column, and a foreign key to the
# groups table, which cascades group deletion to users is created:
# 
#   class CreateUsers < ActiveRecord::Migration
#     def self.up
#       create_table :users do |t|
#         t.references :group_id, :ondelete => CASCADE
#         t.string     :name,     :index => true
#         t.string     :email,    :unique => true
#       end
#     end
#   
#     def self.down
#       drop_table :users
#     end
#   end
# 
module I10::ActiveRecord::CuteIndexes
  
  # index column struct
  class IndexColumnDefinition < Struct.new :name, :index, :unique, :references, :ondelete, :onupdate # :nodoc:
    def to_sql
      case
      when index
        'INDEX (`%s`)' % name
      when unique
        'UNIQUE (`%s`)' % name
      when references
        reference_table = references == true ? name.gsub(/_id$/, '').pluralize : references
        r = 'FOREIGN KEY (`%s`) REFERENCES `%s` (`id`)' % [name, reference_table]
        r += ' ON DELETE %s' % ondelete if ondelete
        r += ' ON UPDATE %s' % onupdate if onupdate
        r
      else
        raise 'invalid index column: %s' % references.class.name
      end
    end
    alias to_s to_sql
  end
  
  # on inclusion
  def self.included(base) # :nodoc:
    base.class_eval do
      
      alias column_without_index column
      # override column method to allow indexing
      def column(name, type, options = {}) # :nodoc:
        column_without_index name, type, options
        if options[:index] or options[:unique] or options[:references]
          @columns << IndexColumnDefinition.new(name, options[:index], options[:unique], options[:references], options[:ondelete], options[:onupdate])
        end
        self
      end
      
      alias references_without_index references
      # override references method to add the references option
      def references(*args) # :nodoc:
        options = args.extract_options!
        options[:references] = true unless options[:polymorphic]
        args << options
        references_without_index *args
      end
      
      # override timestamps to allo options propagation
      def timestamps(options = {}) # :nodoc:
        column(:created_at, :datetime, options)
        column(:updated_at, :datetime, options)
      end
  
    end
  end
  
end