class AddFieldsToEnrollments < ActiveRecord::Migration
  def self.up
    add_column :enrollments, :past_conferences_this, :boolean
    add_column :enrollments, :past_sv_this, :boolean
    add_column :enrollments, :visa, :boolean
    add_column :enrollments, :local_experience, :boolean
  end

  def self.down
    remove_column :users, :past_conferences_this
    remove_column :users, :past_sv_this
    remove_column :users, :visa
    remove_column :users, :local_experience
  end
end
