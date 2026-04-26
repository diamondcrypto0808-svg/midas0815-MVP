Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      post 'auth/logout', to: 'auth#logout'
      post 'auth/refresh', to: 'auth#refresh'
      post 'auth/password/reset', to: 'auth#request_password_reset'
      put 'auth/password', to: 'auth#reset_password'

      # Users
      resources :users, only: [:show, :update] do
        member do
          get :profile
          put :profile, action: :update_profile
          post :avatar, action: :upload_avatar
        end
      end

      # Contents
      resources :contents do
        member do
          post :publish
          get :versions
          post :revert
        end
      end

      # Posts (SNS)
      resources :posts, only: [:index, :create, :show, :destroy] do
        member do
          post :like
          delete :like, action: :unlike
        end
        resources :comments, only: [:index, :create], controller: 'comments'
      end

      # Matching
      namespace :matches do
        get :candidates, to: 'candidates#index'
        resources :requests, only: [:index, :create, :update]
      end
      resources :matches, only: [:index]

      # Analytics
      namespace :analytics do
        get :dashboard
        get :reports
      end
      resources :analytics, only: [] do
        collection do
          get :events, to: 'analytics#events'
          post :events, to: 'analytics#create_event'
        end
      end

      # Search
      get 'search', to: 'search#index'
      get 'search/users', to: 'search#users'
      get 'search/posts', to: 'search#posts'
      get 'search/contents', to: 'search#contents'

      # Notifications
      resources :notifications, only: [:index] do
        member do
          put :read, action: :mark_as_read
        end
        collection do
          put :settings, action: :update_settings
        end
      end
    end
  end

  # WebSocket
  mount ActionCable.server => '/cable'
end
