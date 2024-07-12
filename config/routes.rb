Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :activities, only: %i[create destroy]

      resources :links, only: %i[create destroy]

      resources :trips do
        member do
          get :confirm
          get :activities
          get :links
        end
      end

      resources :participants, only: %i[index] do
        get :confirm, on: :member
      end
    end
  end
end
