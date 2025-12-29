Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :branches, only: [] do
        resources :users
      end

      resources :users

      resources :sessions, only: [:create]
    end
  end

  get "up" => "rails/health#show"
end