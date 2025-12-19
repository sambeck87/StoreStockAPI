Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create]
      resources :sessions, only: [:create]
    end
  end

  get "up" => "rails/health#show"
end