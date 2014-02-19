ActionController::Routing::Routes.draw do |map|

# chi routes
  map.connect ':conference_name/:controller/:action/:id'
  map.connect ':conference_name/:controller/:action/:id'
  map.connect ':conference_name/', :controller => 'main', :action => 'index'
  
  # Named Routes
  map.login ':conference_name/login',   :controller => 'main', :action => 'login'
  map.logout ':conference_name/logout', :controller => 'main', :action => 'logout'
  
  map.root :controller => 'main', :action => 'select_conference'
  
end
