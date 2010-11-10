ActionController::Routing::Routes.draw do |map|

  ***REMOVED*** custom mappings... find out why for instance, categories/json isn't mapped to by the map.resources calls.

  map.courses_json '/courses/json', :controller => 'courses', :action => 'json' 
  map.categories_json '/categories/json', :controller => 'categories', :action => 'json'
  map.proglangs_json '/proglangs/json', :controller => 'proglangs', :action => 'json' 


  map.resources :pictures

***REMOVED***  map.connect '/jobs/list', :controller => 'jobs', :action => 'index'
  map.resources :jobs

  map.resources :reviews

  map.resources :categories 

  map.resources :documents

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  
  map.resources :users
  
  map.resource :session

  ***REMOVED*** The priority is based upon order of creation: first created -> highest priority.

  ***REMOVED*** Sample of regular route:
  ***REMOVED***   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  ***REMOVED*** Keep in mind you can assign values other than :controller and :action

  ***REMOVED*** Sample of named route:
  ***REMOVED***   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  ***REMOVED*** This route can be invoked with purchase_url(:id => product.id)

  ***REMOVED*** Sample resource route (maps HTTP verbs to controller actions automatically):
  ***REMOVED***   map.resources :products

  ***REMOVED*** Sample resource route with options:
  ***REMOVED***   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  ***REMOVED*** Sample resource route with sub-resources:
  ***REMOVED***   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  ***REMOVED*** Sample resource route with more complex sub-resources
  ***REMOVED***   map.resources :products do |products|
  ***REMOVED***     products.resources :comments
  ***REMOVED***     products.resources :sales, :collection => { :recent => :get }
  ***REMOVED***   end

  ***REMOVED*** Sample resource route within a namespace:
  ***REMOVED***   map.namespace :admin do |admin|
  ***REMOVED***     ***REMOVED*** Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  ***REMOVED***     admin.resources :products
  ***REMOVED***   end

  ***REMOVED*** You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  ***REMOVED*** map.root :controller => "welcome"
  
  map.root :controller => "home"
  
  ***REMOVED*** See how all your routes lay out with "rake routes"

  ***REMOVED*** Install the default routes as the lowest priority.
  ***REMOVED*** Note: These default routes make all actions in every controller accessible via GET requests. You should
  ***REMOVED*** consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
