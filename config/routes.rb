Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :sessions, only: [:create]
      resource :registration, only: [:create]
      resources :global_permissions

      resources :users, only: [:index, :show, :update, :destroy]
      resources :roles
      resources :categories do
        resources :items
      end

      resources :branches do
        resources :users, only: [:index, :show, :update, :destroy]
      end

      namespace :admin do
        resources :users, only: [] do
          member do
            patch :manage
            delete "branches/:branch_id", to: "users#revoke_access"
          end
        end
      end

      resources :stores, only: [:index, :show, :create, :update, :destroy] do
        resources :users, only: [:index, :show, :update, :destroy]
      end
    end
  end

  get "up" => "rails/health#show"
end