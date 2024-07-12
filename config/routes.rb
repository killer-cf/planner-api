Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :activities, except: %i[show update]

      resources :trips do
        get :confirm, on: :member
      end

      resources :participants, only: %i[index] do
        get :confirm, on: :member
      end
    end
  end
end
