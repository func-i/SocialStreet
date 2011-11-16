SocialStreetReborn::Application.routes.draw do
  root :to => 'explore#index'

  get 'explore' => 'explore#search', :as => 'explore'

  resources :event_types, :only => [:index]
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
  end

  resources :profiles do
    collection do
      get 'add_group'
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

  match '/contact' => 'contact#create'

  match '/locations/update_user_location' => 'locations#update_user_location'

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations" }

  match '/auth/:provider/callback' => 'authentications#create'

  get 'hb' => 'heartbeat#index'
  get 'sim_error' => 'heartbeat#error'

  namespace :m do #mobile
    root :to => 'site#index'
    
    get 'explore' => 'explore#index', :as => 'explore'

    #get 'events/new' => 'events#new', :as => 'create'
    resources :events do
      resources :event_rsvps, :only => [:new, :edit]
      resources :invitations, :only => [:new, :create]
    end    
  end
end
