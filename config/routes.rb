Rails.application.routes.draw do


  resources :admins do

    collection do


    end
    member do
      get 'checkout'
      get 'return'
      get 'reserve'
      get 'search'
      get 'showcar_customer'
      get 'mycar'
      get 'all_customers'
      #get 'edit_customer'
      #get 'update_customer'
    end
  end
  get '/admins/:id_admin/show_customer/:id_customer', to: 'admins#show_customer', as: 'show_admin_customer'
  get '/admins/:id_admin/edit_customer/:id_customer', to: 'admins#edit_customer', as: 'edit_admin_customer'
  patch '/admins/:id_admin/show_customer/:id_customer', to: 'admins#update_customer'#, as: 'update_admin_customer'
  put '/admins/:id_admin/show_customer/:id_customer', to: 'admins#update_customer'#, as: 'update_admin_customer'
  #, as: 'destroy_admin_customer'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  root 'customers#index'

  delete '/admins/:id_admin/show_customer/:id_customer', to: 'customers#destroy'

  resources :customers do
    collection do


    end
    member do
      get 'checkout'
      get 'return'
      get 'reserve'
      get 'search'
      get 'showcar_customer'
      get 'myhistory'
    end
  end
  #delete '/admins/:id_admin/show_customer/:id_customer', to: 'customers#destroy'
  resources :records


  resources :cars do

  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
