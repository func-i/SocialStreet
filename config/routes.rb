SocialStreetReborn::Application.routes.draw do
  get "smows/_form"

  get "smows/new"

  get "smows/edit"

  get "smows/index"

  root :to => 'explore#index'

  get 'explore' => 'explore#search', :as => 'explore'
  get 'invalid_browser' => 'authentications#invalid_browser', :as => "invalid_browser"

  resources :event_types, :only => [:index]

  match "e/:id" => redirect("http://www.socialstreet.com/events/%{id}")
  match "e/smow" => redirect("http://www.socialstreet.com/events/streetmeet_of_the_week")
  resources :events do
    collection do
      match 'streetmeet_of_the_week'
    end

    member do
      match 'create_message'
      match 'send_message'
    end

    resources :event_rsvps, :only => [:new, :edit]
    resources :invitations, :only => [:new]
    resources :comments, :only => [:create, :destroy]
    resources :smows do
      member do
        match "send_single_email"
        match "send_smow"
      end      
    end
  end

  resources :profiles do
    collection do
      get 'add_group'
    end

    member do
      get 'socialcard'
    end
  end

  resources :invitations, :only => [] do
    collection do
      get "load_connections"
    end
  end
  
  resources :authentications do
    collection do
      match "show_privacy"
      match "show_tnc"
      match "show_signins"
    end
  end

  resources :groups do
    collection do
      get 'apply_for_membership'
    end

    member do
      post 'search_user_groups'
    end

    resources :user_groups
  end

  resources :smows

  match '/contact' => 'contact#create'

  match '/locations/update_user_location' => 'locations#update_user_location'

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations" }

  match '/auth/:provider/callback' => 'authentications#create'

  get 'hb' => 'heartbeat#index'
  get 'sim_error' => 'heartbeat#error'

  get '/connections/facebook_realtime' => 'facebook_realtime#update'
  post '/connections/facebook_realtime' => 'facebook_realtime#update'

  namespace :m do #mobile
    root :to => 'site#index'
    
    get 'explore' => 'explore#index', :as => 'explore'

    #get 'events/new' => 'events#new', :as => 'create'
    resources :events do
      resources :event_rsvps, :only => [:new, :edit]
      resources :invitations, :only => [:new, :create] do
        collection do
          get "search"
        end
      end
      resources :comments, :only => [:create]
    end    
  end

  match "*r", redirect{|p, request| request.url.gsub(/scl\.st/, "socialstreet.com")}, :constraints => [:host => 'scl.st']
end
