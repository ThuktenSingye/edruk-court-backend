Rails.application.routes.draw do
  devise_for :users, skip: [ :sessions, :registrations, :passwords, :confirmations ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :test, only: [ :index ]

  # Subdomain constraints
  constraints subdomain: /.*/ do
    devise_for :users, path: "api/v1/auth", controllers: {
      sessions: "api/v1/auth/sessions",
      registrations: "api/v1/auth/registrations",
      passwords: "api/v1/auth/passwords",
      confirmations: "api/v1/auth/confirmations"
    }

    namespace :api do
      namespace :v1 do
        resources :profiles, only: [ :show, :update] do
          resources :addresses, only: [ :create ]
        end
      end
    end
  end
end
