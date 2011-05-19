ResearchMatch::Application.routes.draw do

  get  'courses_json'    => 'courses***REMOVED***json'
  get  'categories_json' => 'categories***REMOVED***json'
  get  'proglangs'       => 'proglangs***REMOVED***json'

  resources :pictures

  ***REMOVED*** Jobs
  scope '/jobs', :as => :jobs do
    get  '/activate/:id' => 'jobs***REMOVED***activate', :as => :activate
    get  '/search' => 'jobs***REMOVED***index', :as => :search
  end
  resources :jobs

  ***REMOVED*** Applics
  scope :applics do
    get  '/jobs/:job_id/apply' => 'applics***REMOVED***new', :as => :new_job_applic
    get  '/jobs/:job_id/doapply' => 'applics***REMOVED***create', :method => 'post', :as => :create_job_applic
    get  '/jobs/:job_id/applications' => 'applics***REMOVED***index', :as => :list_jobs_applics
    get  '/applications/:id' => 'applics***REMOVED***show', :as => :applic
    get  '/applications/:id/withdraw' => 'applics***REMOVED***destroy', :as => :destroy_applic
    get  '/applications/:id/resume' => 'applics***REMOVED***resume', :as => :applic_resume
    get  '/applications/:id/transcript'=>'applics***REMOVED***transcript', :as => :applic_transcript
  end ***REMOVED*** applics

  ***REMOVED*** Categories
  resources :categories

  ***REMOVED*** Documents
  resources :documents

  ***REMOVED*** Access control
  match '/logout' => 'sessions***REMOVED***destroy'
  match '/login'  => 'sessions***REMOVED***new'
  resources :session

  ***REMOVED*** Users
  resources :users
  get  '/dashboard' => 'dashboard***REMOVED***index'

  ***REMOVED*** Home
  get  '/' => 'home***REMOVED***index'


  ***REMOVED*** The priority is based upon order of creation:
  ***REMOVED*** first created -> highest priority.

  ***REMOVED*** Sample of regular route:
  ***REMOVED***   match 'products/:id' => 'catalog***REMOVED***view'
  ***REMOVED*** Keep in mind you can assign values other than :controller and :action

  ***REMOVED*** Sample of named route:
  ***REMOVED***   match 'products/:id/purchase' => 'catalog***REMOVED***purchase', :as => :purchase
  ***REMOVED*** This route can be invoked with purchase_url(:id => product.id)

  ***REMOVED*** Sample resource route (maps HTTP verbs to controller actions automatically):
  ***REMOVED***   resources :products

  ***REMOVED*** Sample resource route with options:
  ***REMOVED***   resources :products do
  ***REMOVED***     member do
  ***REMOVED***       get 'short'
  ***REMOVED***       post 'toggle'
  ***REMOVED***     end
  ***REMOVED***
  ***REMOVED***     collection do
  ***REMOVED***       get 'sold'
  ***REMOVED***     end
  ***REMOVED***   end

  ***REMOVED*** Sample resource route with sub-resources:
  ***REMOVED***   resources :products do
  ***REMOVED***     resources :comments, :sales
  ***REMOVED***     resource :seller
  ***REMOVED***   end

  ***REMOVED*** Sample resource route with more complex sub-resources
  ***REMOVED***   resources :products do
  ***REMOVED***     resources :comments
  ***REMOVED***     resources :sales do
  ***REMOVED***       get 'recent', :on => :collection
  ***REMOVED***     end
  ***REMOVED***   end

  ***REMOVED*** Sample resource route within a namespace:
  ***REMOVED***   namespace :admin do
  ***REMOVED***     ***REMOVED*** Directs /admin/products/* to Admin::ProductsController
  ***REMOVED***     ***REMOVED*** (app/controllers/admin/products_controller.rb)
  ***REMOVED***     resources :products
  ***REMOVED***   end

  ***REMOVED*** You can have the root of your site routed with "root"
  ***REMOVED*** just remember to delete public/index.html.
  ***REMOVED*** root :to => "welcome***REMOVED***index"

  ***REMOVED*** See how all your routes lay out with "rake routes"

  ***REMOVED*** This is a legacy wild controller route that's not recommended for RESTful applications.
  ***REMOVED*** Note: This route will make all actions in every controller accessible via GET requests.
  ***REMOVED*** match ':controller(/:action(/:id(.:format)))'
end
