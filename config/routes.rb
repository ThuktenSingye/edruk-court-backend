Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount ActionCable.server => "/cable"
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
        namespace :admin do
          resources :courts
        end
        resources :users, only: [] do
          resource :profile, only: %i[show update] do
            resources :addresses, only: %i[create]
          end
        end

        resources :hearing_schedules, controller: '/api/v1/case/hearing_schedules' do
          collection do
            get :today
            get :pending
            get :reminders
            get :overdue
          end
        end

        scope module: :case do
          resources :cases, except: %i[destroy] do
            collection do
              get :statistics
            end
            member do
              get :files
            end
            resources :hearings, except: %i[destroy] do
              resources :notes
              resources :hearing_schedules
              resources :case_documents, path: :documents
              resources :case_evidences, path: :evidences
            end
          end
        end
      end
    end
  end
end
