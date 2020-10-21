Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      get '/items/find_all', to: 'items/search#index'
      get '/items/find', to: 'items/search#show'
      resources :items do
        get :merchants, to: 'items/merchants#show'
      end

      get '/merchants/find_all', to: 'merchants/search#index'
      get '/merchants/find', to: 'merchants/search#show'
      resources :merchants do
        get :items, to: 'merchants/items#index'
      end
    end
  end
end
