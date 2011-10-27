SocialStreetReborn::Application.routes.draw do
  get "groups/show"

  root :to => 'explore#index'

  get 'explore' => 'explore#search', :as => 'explore'

  resources :event_types, :only => [:index]
  resources :events do
    collection do
      match 'streetmeet_of_the_week'
    end
    resources :event_rsvps, :only => [:new, :edit]
    resources :invitations, :only => [:new]
    resources :comments, :only => [:create, :destroy]
  end

  resources :profiles

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

  resources :groups

  match '/contact' => 'contact#create'

  match '/locations/update_user_location' => 'locations#update_user_location'

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations" }

  match '/auth/:provider/callback' => 'authentications#create'

  get 'hb' => 'heartbeat#index'
  get 'sim_error' => 'heartbeat#error'
end
