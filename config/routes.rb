Svportal::Application.routes.draw do
  
  # client routes
  match ':conference_name/:controller(/:action(/:id))'
  match ':conference_name/' => 'main#index'
  
  # named routes
  match ':conference_name/login' => 'main#login', :as => 'login'
  match ':conference_name/logout' => 'main#logout', :as => 'logout'
  
  # root
  root :to => 'main#select_conference'
  
end
