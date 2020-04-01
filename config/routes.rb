Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  get 'home/index'

  get 'csv/:type', to: 'csv#create'

  root to: 'home#index'

  resources :donors, only: [:index, :show, :update] do
    post :sync_to_onfleet, on: :member
    post :geocode, on: :member
    get :manual_geocode, on: :member
    get :onfleet_task, on: :member
  end

  namespace 'api' do
    resources :donors, only: [:index] do
      get :sync, on: :collection
      get :sync_to_onfleet
    end
    resources :hospitals, only: [:index]
    resources :drivers, only: [:index]

    resources :onfleet_webhook_requests, only: [:index, :create]
  end
end
