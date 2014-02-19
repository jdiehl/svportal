class Admin::AdminUserController < AdminController
  
  def index
    @admin_users = AdminUser.find :all, :order => 'login'
  end
  
end
