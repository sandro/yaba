ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages'

  # Named Routes
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # Resources
  map.resource :session, :collection => {:complete => :get, :email => :get}
  map.resources :users, :collection => {
      :activate => :get,
      :forgot_password => :get,
      :send_forgotten_password => :put,
      :reset => :get,
      :reset_password => :put}
end
