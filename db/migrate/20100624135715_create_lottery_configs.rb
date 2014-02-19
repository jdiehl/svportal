class CreateLotteryConfigs < ActiveRecord::Migration
  def self.up
    # rename no_visa to visa
    add_column :enrollments, :visa, :boolean
    execute 'update enrollments set visa = !no_visa'
    remove_column :enrollments, :no_visa
    
    create_table :lottery_configs do |t|
      t.integer :conference_id, :null => false
      t.integer :local_experience
      t.integer :past_conferences_this
      t.integer :past_sv_this
      t.integer :visa
      t.timestamps
    end
    add_foreign_key :lottery_configs, :conference_id, :conferences
  end

  def self.down
    # rename no_visa to visa
    add_column :enrollments, :no_visa, :boolean
    execute 'update enrollments set no_visa = !visa'
    remove_column :enrollments, :visa

    drop_table :lottery_configs
  end
end
