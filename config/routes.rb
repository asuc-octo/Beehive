ResearchMatch::Application.routes.draw do

  get "contact_us/contact", :as => :contact_us
  post "contact_us/send_email", :as => :feedback_email_link

  resources :pictures

  ***REMOVED*** Jobs
  scope '/jobs', :as => :jobs do
    get  '/search' => 'jobs***REMOVED***index', :as => :search
  end

  resources :jobs do
    member do
      get 'activate'
      get 'delete'
      get 'resend_activation_email'
      get 'watch'
      get 'unwatch'
    end
  end

  ***REMOVED***Intro
  get '/intro', :to => 'intro***REMOVED***intro'

  ***REMOVED***Team
  get '/team', :to => 'team***REMOVED***team'

  ***REMOVED*** Applics
  scope :applics do
    get  '/jobs/:job_id/apply' => 'applics***REMOVED***new', :as => :new_job_applic
    post '/jobs/:job_id/apply' => 'applics***REMOVED***create', :as => :create_job_applic
    get  '/jobs/:job_id/applications' => 'applics***REMOVED***index', :as => :list_jobs_applics
    get  '/applications/:id' => 'applics***REMOVED***show', :as => :applic
    get  '/applications/:id/withdraw' => 'applics***REMOVED***destroy', :as => :destroy_applic
    get  '/applications/:id/delete' => 'applics***REMOVED***delete', :as => :delete_applic
    post '/applications/:applic_id' => 'applics***REMOVED***accept'
    post '/applications/:applic_id/unaccept' => 'applics***REMOVED***unaccept'
    ***REMOVED***get  '/applications/:id/resume' => 'applics***REMOVED***resume', :as => :applic_resume
    ***REMOVED***get  '/applications/:id/transcript'=>'applics***REMOVED***transcript', :as => :applic_transcript
  end ***REMOVED*** applics

  ***REMOVED*** Documents
  ***REMOVED*** post '/documents/:id/destroy' => 'documents***REMOVED***destroy', :as => :destroy_document
  resources :documents

  ***REMOVED*** Access control
  get '/logout' => 'user_sessions***REMOVED***destroy'
  ***REMOVED***match '/login'  => 'user_sessions***REMOVED***new'
  get '/login'  => redirect('/auth/cas')
  get '/auth/:provider/callback' => 'user_sessions***REMOVED***new'

  ***REMOVED*** Users
  resources :users
  get  '/dashboard' => 'dashboard***REMOVED***index', :as => :dashboard
  get  '/profile'   => 'users***REMOVED***profile', :as => :profile

  ***REMOVED*** Faculty
  resources :faculties, only: :show
  ***REMOVED*** Home
  get  '/' => 'home***REMOVED***index', :as => :home

  ***REMOVED*** Orgs
  resources :orgs, param: :abbr
  post '/orgs/:abbr/curate' => 'orgs***REMOVED***curate', :as => :orgs_curate
  post '/orgs/:abbr/uncurate' => 'orgs***REMOVED***uncurate', :as => :orgs_uncurate

  ***REMOVED*** Statistics
  get '/statistics'      => 'statistics***REMOVED***index', :as => :statistics

  ***REMOVED*** Autocomplete routes
  get '/categories/json' => 'categories***REMOVED***json', :as => :categories_json, :defaults => {format: 'json'}
  get '/courses/json' => 'courses***REMOVED***json', :as => :courses_json, :defaults => {format: 'json'}
  get '/proglangs/json' => 'proglangs***REMOVED***json', :as => :proglangs_json, :defaults => {format: 'json'}

  ***REMOVED*** Admin
  get '/admin' => 'admin***REMOVED***index', :as => :admin
  post '/admin/upload' => 'admin***REMOVED***upload', :as => :admin_upload

  ***REMOVED*** get  '/faculties' => 'faculties***REMOVED***index', :as => :faculties
  ***REMOVED*** put  'faculties/:id' => 'faculties***REMOVED***update', :as => :faculties_update
  ***REMOVED*** delete 'faculties/:id' => 'faculties***REMOVED***destroy', :as => :faculties_destroy
  ***REMOVED*** post 'faculties' => 'faculties***REMOVED***create', :as => :faculties_create

  root :to => 'home***REMOVED***index'

  get '/test_error(/:code)' => 'application***REMOVED***test_exception_notification'

  ***REMOVED*** Routing for Errors
  get "*any", via: :all, to: "errors***REMOVED***not_found"

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
