# Extends ActiveRecord::Migration with several useful operations
# 
# The add_index and add_foreign_key methods are legacy methods. Please use
# I10::ActiveRecord::CuteIndexes instead.
# 
# Note that many of the defined methods will only work with a MySQL database
# and InnoDB tables.
# 
# == Examples
# 
# === Using Foreign Keys
# 
# This migration makes use of the add_index and add_foreign_key methods to
# create a users table with an index on the name column, a unique index on the
# email column, and a foreign key to the groups table, which cascades group
# deletion to users:
# 
#   class CreateUsers < ActiveRecord::Migration
#     def self.up
#       create_table :users do |t|
#         t.references :group_id
#         t.string     :name
#         t.string     :email
#       end
#       add_index       :users, :name
#       add_index       :users, :email, :unique => true
#       add_foreign_key :users, :group_id, :ondelete => CASCADE
#     end
#   
#     def self.down
#       drop_table :users
#     end
#   end
# 
# === Importing data
# 
# This migration imports records from a csv file into the users table and
# truncates (empties and resets all counters) the table when reverted:
# 
#   class ImportUsers < ActiveRecord::Migration
#     def self.up
#       import_csv :users, 'db/import/users.csv'
#     end
#   
#     def self.down
#       truncate :users
#     end
#   end
# 
module I10::ActiveRecord::MigrationExtension
  MAX_INSERTS_PER_QUERY = 100
  
  RESTRICT = 'RESTRICT'
  CASCADE  = 'CASCADE'
  NULL     = 'NULL'
  NONE     = 'NONE'

  # called upon including
  def self.included(base) # :nodoc:

    # change class definition
    base.class_eval do
      class << self
        
        # Overrides the Rails method to create an index to allow more options
        # 
        # ==== Parameters
        # 
        # * table_name: name of the table to add the index to
        # * column_name: name of the column, which should be indexed
        # * options: options hash:
        # 
        #   :unique => true: create a unique index
        #   :fulltext => true: create a fulltext index
        #   :size => true: size of the index
        #   :foreign => [reference_table, reference_key]: create a foreigh key for the given table and key
        #   :ondelete => (RESTRICT|CASCADE|NULL|NONE): define the behavior for deleting the referenced row
        #   :onupdate => (RESTRICT|CASCADE|NULL|NONE): define the behavior for changing the referenced row
        # 
        def add_index(table_name, column_name, options = {}) # :nodoc:
          column_names = Array(column_name)
          index_name   = index_name(table_name, :column => column_names)
      
          if Hash === options # legacy support, since this param was a string
            index_type = ''
            index_type = 'UNIQUE'   if options[:unique]
            
            # allow fulltext indexes
            index_type = 'FULLTEXT' if options[:fulltext]
            index_name = options[:name] || index_name
          else
            index_type = options
          end
          quoted_column_names = column_names.map { |e| quote_column_name(e) }.join(", ")
          
          size = ''
          size = ' (%i)' % options[:size] unless options[:size].nil?
          
          execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)}#{size} ON #{table_name} (#{quoted_column_names})"
          
          # we are done unless we want a foreign key
          return unless options[:foreign]
          
          # retrieve reference table and key
          foreign_table, foreign_key = options[:foreign]
          
          # default restrictions
          options[:ondelete] ||= 'RESTRICT'
          options[:onupdate] ||= 'CASCADE'
          
          # change the table and add the foreign key
          execute "ALTER TABLE `%s` ADD FOREIGN KEY (`%s`) REFERENCES `%s` (`%s`) ON DELETE %s ON UPDATE %s" %
            [table_name, column_names.first, foreign_table, foreign_key, options[:ondelete], options[:onupdate]]
        end
      
        # Add a foreign key with index to the table
        # 
        # ==== Parameters
        # 
        # * table_name: name of the table to add the foreign key reference to
        # * column_name: name of the column, which is the reference key
        # * reference: reference table (can be derived from the column_name)
        # * key: primary key of the reference table (defaults to id)
        # * options hash (see add_index for a description)
        # 
        def add_foreign_key(table_name, column_name, reference = nil, key = 'id', options = {})
          reference ||= column_name.to_s.gsub(/_id$/,'').pluralize
          options[:foreign] = [reference, key]
          add_index table_name, column_name, options
        end

        # Insert several rows at once into a table.
        # 
        # ==== Parameters
        # * table_name: name of the table to insert the values into
        # * column_names: column names for the values
        # * rows: array of row arrays
        # * options: options hash:
        #   :ignore => true: ignore errors when inserting
        # 
        def import(table_name, column_names, rows, options = {})

          # retrieve ignore option
          ignore = options.delete :ignore

          # debug output
          say_with_time 'importing into %s' % table_name do 
            suppress_messages do

              # quote the column names
              column_names.collect! { |i| quote_column_name i }

              # cache the length of the columns
              num_cols = column_names.length

              # start constructing the query
              sqry  = 'insert '
              sqry += 'ignore ' if ignore
              sqry += 'into `%s` (%s) values ' % [table_name, column_names.join(',')]
              qry = ''

              # iterate over all rows
              cnt = 0
              i = 0
              rows = rows.each do |row|
                # ignore empty lines
                next if row.nil? or row.empty?

                # add a comma unless we are at the first row
                # this method is faster than using join over an array
                qry += ',' unless i == 0
                i += 1
                cnt += 1

                # quote values
                row.collect! { |v| my_quote v }

                # raise an error if the number of values does not match the number of 
                # columns
                raise 'row %i does not match columns' % cnt if row.length != num_cols

                # add the row to the query
                qry += '(%s)' % row.join(',')

                # execute query for 100 rows
                if i == MAX_INSERTS_PER_QUERY
                  execute sqry+qry
                  qry = ''
                  i = 0
                end

                # avoid excessive load
                sleep 0.001
              end

              # run query
              execute sqry+qry unless qry.empty?
            end
          end
        end

        # Import data from a CSV file.
        # 
        # Note that the CSV file must be properly formatted and contain a header row.
        # 
        # Required GEM: FasterCSV
        # 
        # ==== Parameters
        # * table_name: name of the table to import that data into
        # * csv_filepath: path to the csv file (relative to Rails root)
        # 
        def import_csv(table_name, csv_filepath)
          require 'fastercsv'
          csv = FasterCSV.open csv_filepath, 'r', :col_sep => "\t"
          column_names = csv.shift
          import table_name, column_names, csv
        end

        # Truncate a table (empty it and reset all counters)
        # 
        # ==== Parameters
        # 
        # * table_name: name of the table to be truncated
        # 
        def truncate(table_name)
          say_with_time 'truncating %s' % table_name do 
            suppress_messages do
              execute 'truncate table %s' % table_name
            end
          end
        end

        # Drop an index
        # 
        # ==== Parameters
        # 
        # * table_name: name of the table to drop the index from
        # * column_name: name of the column (or columns) in the index
        # * options: optional options hash with:
        #   :name => name of the index to be dropped
        def drop_index(table_name, column_names, options = {})
          column_names = [column_names] unless column_names.is_a? Array
          index_name   = options.delete :name
          index_name ||= 'index_%s_on_%s' % [table_name, column_names.join('_and_')]
          say_with_time 'dropping index %s' % index_name do
            suppress_messages do
              execute 'alter table %s drop index %s' % [table_name, index_name]
            end
          end
        end

        protected

        # quote a value according to its type
        def my_quote(v) # :nodoc:
          # numeric
          if v.is_a? Fixnum or v.is_a? Float
            v
          # nil
          elsif v.nil? or v == ''
            'NULL'
          else
            quote v
          end
        end

      end
    end
  end
end