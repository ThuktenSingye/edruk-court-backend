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

  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :court_orders do
          collection do
            get :sent
          end
        end

        resources :courts do
          collection do
            get :statistics
            get :court_types
          end
        end
        resources :users do
          collection do
            get :judge
            get :clerk
            get :registrar
          end
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :user do
        resources :court_orders do
          collection do
            get :received
          end
        end

        resources :cases do
          member do
            get :files
          end
          collection do
            get :active
          end
          resources :hearings, only: [ :index ] do
            resources :case_documents, path: :documents do
              member do
                post :sign
              end
              collection do
                post :sign_all
              end
            end
            resources :hearing_schedules, only: [ :index ]
          end
        end

        resources :hearing_schedules, controller: '/api/v1/user/hearing_schedules' do
          collection do
            get :reminders
            get :list
          end
        end

      end
    end
  end

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
        resources :court_orders do
          collection do
            get :sent
            get :received
          end
        end
        resources :hearing_types, only: [ :index ]

        resources :benches, only: [ :index ]

        resources :notifications, only: [ :index ] do
          member do
            post :mark_as_read
          end
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
            get :month
            get :list
          end
        end

        scope module: :case do
          resources :cases, except: %i[destroy] do
            collection do
              get :statistics
            end
            member do
              get :files
              post :sign_all
            end
            post 'documents/:doc_id/sign', to: 'cases#sign', as: :sign_case_documents
            resources :hearings, except: %i[destroy] do
              resources :notes
              resources :hearing_schedules
              resources :case_documents, path: :documents do
                member do
                  post :sign
                end
                collection do
                  post :sign_all
                end
              end
              resources :case_evidences, path: :evidences
            end
          end
        end
      end
    end
  end
end
