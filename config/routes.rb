Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :items do
        get '/find_all', to: 'search#index'
        get '/find', to: 'search#show'
      end
      resources :items do
        get :merchants, to: 'items/merchants#show'
      end

      namespace :merchants do
        get '/find_all', to: 'search#index'
        get '/find', to: 'search#show'
        get '/most_revenue', to: 'business_intelligence#most_revenue'
        get '/most_items', to: 'business_intelligence#most_items'
      end
      resources :merchants do
        get :revenue, to: 'merchants/business_intelligence#total_revenue'
        get :items, to: 'merchants/items#index'
      end

      get '/revenue', to: 'merchants/business_intelligence#revenue_over_range'
    end
  end
end
