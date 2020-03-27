Rails.application.routes.draw do
  devise_for :users

  get 'home/index'

  get 'csv/:type', to: 'csv#create'

  root to: 'home#index'

  namespace 'api' do
    resources :donors, only: [:index] do
      get :sync, on: :collection
      get :sync_to_onfleet
    end
    resources :hospitals, only: [:index]
    resources :drivers, only: [:index]
  end
end
