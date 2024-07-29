Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[show] do
        collection do
          post :create_webhook
          post :update_webhook
          post :destroy_webhook
        end
      end

      resources :activities, only: [:destroy, :update]

      resources :links, only: [:destroy]

      resources :trips do
        member do
          get :confirm
          get :participants
          get :activities
          get :links
          post :invites
          post :activities, to: 'activities#create'
          post :links, to: 'links#create'
        end
      end

      resources :participants, only: %i[show destroy update] do
        get :confirm, on: :member
      end
    end
  end
end
