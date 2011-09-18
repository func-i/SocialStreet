SocialStreetReborn::Application.routes.draw do
  root :to => 'explore#index'

  get 'explore' => 'explore#search', :as => 'explore'

  resources :event_types, :only => [:index]
  resources :events do
    resources :event_rsvps, :only => [:new, :edit] do
      member do
        get "search"
      end
    end
    resources :comments, :only => [:create]
  end

  resources :authentications do
    collection do
      match "accept_tnc"
      match "tnc_accepted"
      match "show_privacy"
    end
  end

  devise_for :users, :controllers => { :sessions => "sessions", :registrations => "registrations" }

  match '/auth/:provider/callback' => 'authentications#create'

end
