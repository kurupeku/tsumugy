Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # NASA Game routes
  namespace :nasa_game do
    # Facilitator: session management
    resources :sessions, only: %i[new create show update]

    # Participant flow - groups/:id is the entry point (shared via invitation link)
    resources :groups, only: %i[show] do
      # Participant registration nested under group (join via invitation link)
      resources :participants, only: %i[new create]
      # Group rankings (team consensus)
      resources :group_rankings, only: %i[create update]
    end

    # Participant's own pages (after joining)
    resources :participants, only: %i[show update] do
      # Individual rankings belong to participant
      resources :individual_rankings, only: %i[create update]
    end
  end

  # Defines the root path route ("/")
  root "home#index"
end
