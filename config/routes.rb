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

  namespace :api do
    namespace :v1 do
      resources :humans, only: [:show] do
        post :get_human_measures, on: :member  # POST /api/v1/humans/:id/get_human_measures
        # It's an endpoint nested under human. It's a Post because it's a POST request to upload the file.
        post :upload_bioimpedance, on: :member

        post :upload_image_exam, on: :member
      end
    end
  end

  resources :humans, only: [:show] do
    resources :biomarkers, only: [:index, :show] do #{only => [:index, :show]} || Chamando uma funcao resources e de argumento passando uma string e um hash.
    #another syntax: resources("biomarkers", {"only" => ["index", "show"]}) || resources("biomarkers") --> Hash is a change argument for the function.
      resources :measures, only: [:index]
    end
    resources :imaging_reports, only: [:index, :show] do
    end

  end
end
