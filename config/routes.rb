SocialStreet::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  #root :to => 'dashboard#show'
  #root :to => "explore#index"

  root :to => 'site#index'

  get 'how-it-works' => 'site#how', :as => 'how'
  get 'explore' => 'explore#index', :as => 'explore'
  get 'events' => 'events#new', :as => 'create'
  get 'profiles' => 'profiles#index', :as => 'profiles'
  get 'explore/simple_page' => 'explore#simple_page'

  resources :comments, :only => [:create, :destroy]
  resources :event_types, :only => [:index] # for autocomplete
  resources :events do

    member do
      get "post_to_facebook"
    end

    collection do
      match "load_events"
    end

    resources :rsvps do 
      resources :invitations do
        member do
          match "load_modal"
        end
        get :change, :on => :collection
      end
    end

    resources :administrators
    resources :comments, :only => [:create]
  end

  resources :authentications do
    collection do
      match "accept_tnc"
      match "tnc_accepted"
      match "show_privacy"
    end
  end

  resources :actions do
    resources :comments, :only => [:create]
  end

  resources :profiles do
    resources :comments, :only => [:create]
  end

  resource :dashboard, :only => [:show], :controller => :dashboard

  resources :connections do 
    collection do
      match "facebook_realtime"
      match "import_facebook_friends"
      match "import_friends"
    end
  end
  
  resources :locations, :only => [:index] # for AJAX lookup

  resources :feedbacks, :only => [:update, :show] # for providing feedback through the dash

  match '/contact' => 'contact#create'

  resources :search_subscriptions

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations" }

  match '/auth/:provider/callback' => 'authentications#create'

  match '/locations/update_users_location' => 'locations#update_users_location'

  get 'hb' => 'heartbeat#index'
  get 'sim_error' => 'heartbeat#error'
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
