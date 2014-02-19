class AddConferenceId < ActiveRecord::Migration
  def self.up
    add_column :availabilities, :conference_id, :integer
    add_foreign_key :availabilities, :conference_id, :conferences
    remove_column :availabilities, :available
  end

  def self.down
    remove_column :availabilities, :conference_id
    add_column :availabilities, :available, :boolean
  end
end
