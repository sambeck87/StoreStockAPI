Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :sessions, only: [:create]
      resource :registration, only: [:create]

      resources :users, only: [:show, :update, :destroy]

      resources :branches, only: [] do
        resources :users, only: [:index, :show, :update, :destroy]
      end

      namespace :admin do
        resources :users, only: [] do
          member do
            patch :manage
          end
        end
      end

      resources :stores, only: [:index, :show, :create, :update, :destroy] do
        resources :users, only: [:index, :show, :update, :destroy]
        resources :branches
        resources :categories
        resources :items
        resources :roles
      end
    end
  end

  get "up" => "rails/health#show"
end