Rails.application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: "pages#home"
  get "about", to: "pages#about"
  get "/welcome", to: "pages#welcome"
  get "/welcome_draft", to:"pages#welcome_draft"

  namespace :api do
    namespace :v1 do
      resources :humans, only: [:show] do
        resources :blood_historical_measures, only: [:create]
        # Equals to:
        # post '/api/v1/humans/:human_id/blood_historical_measures', to: 'blood_historical_measures#create'
        resources :imaging_reports, only: [:create]
        resources :bioimpedance_measures, only: [:create]
        resources :blood_measures, only: [:create]
      end
    end
  end

  resources :humans, only: [:show] do
    resources :biomarkers, only: [:index, :show] do
      get 'search', on: :collection, to: 'biomarkers#search'

      get 'blood', on: :collection, to: 'biomarkers#blood'
      get 'blood/search', on: :collection, to: 'biomarkers#blood_search'

      # get 'blood', on: :collection, to: 'biomarkers#blood' do
      #   get 'search', on: :collection, to: 'biomarkers#blood_search'
      # end

      get 'bioimpedance', on: :collection, to: 'biomarkers#bioimpedance'
      get 'bioimpedance/search', on: :collection, to: 'biomarkers#bioimpedance_search'


      resources :measures, only: [:index]
    end

    resources :imaging_reports, only: [:index, :show] # url_helper: human_imaging_report_path(human_id: @human.id, id: @imaging_report.id)
  end
end
