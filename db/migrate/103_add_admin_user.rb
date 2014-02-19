class AddAdminUser < ActiveRecord::Migration
  def self.up
    AdminUser.create :login => 'admin', :password => 'admin', :conference_id => nil, :status => 2
  end

  def self.down
    AdminUser.delete_all :login => 'admin'
  end
end
