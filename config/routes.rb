Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :activities, only: [:destroy]

      resources :links, only: [:destroy]

      resources :trips do
        member do
          get :confirm
          get :participants
          get :activities
          get :links
          post :activities, to: 'activities#create'
          post :links, to: 'links#create'
        end
      end

      get 'paticipants/:id/confirm', to: 'participants#confirm'
    end
  end
end
