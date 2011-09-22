SocialStreetReborn::Application.routes.draw do
  root :to => 'explore#index'

  get 'explore' => 'explore#search', :as => 'explore'

  resources :event_types, :only => [:index]
  resources :events do
    resources :event_rsvps, :only => [:new, :edit]
    resources :invitations, :only => [:new]
    resources :comments, :only => [:create, :destroy]
  end

  resources :invitations, :only => [] do
    collection do
      get "search"
      get "load_connections"
    end
  end
  
  resources :authentications do
    collection do
      match "accept_tnc"
      match "tnc_accepted"
      match "show_privacy"
      match "show_tnc"
    end
  end

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations" }

  match '/auth/:provider/callback' => 'authentications#create'

end
