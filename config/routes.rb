Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :items
      get '/merchants/find', to: 'merchants/search#show'
      resources :merchants do
        get :items, to: 'merchants/items#index'
      end
    end
  end
end
