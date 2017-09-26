Rails.application.routes.draw do


  get 'sessions3/new'

  get 'sessions2/new'

  get 'sessions/new'

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


  delete '/admins/:id_admin/show_customer/:id_customer', to: 'customers#destroy'

  get    '/customer_signup',  to: 'customers#new'
  get    '/customer_login',   to: 'sessions#new'
  post   '/customer_login',   to: 'sessions#create'
  delete '/customer_logout',  to: 'sessions#destroy'
  resources :customers

  get    '/admin_signup',  to: 'admins#new'
  get    '/admin_login',   to: 'sessions2#new'
  post   '/admin_login',   to: 'sessions2#create'
  delete '/admin_logout',  to: 'sessions2#destroy'
  resources :admins

  get    '/super_admin_signup',  to: 'super_admins#new'
  get    '/super_admin_login',   to: 'sessions3#new'
  post   '/super_admin_login',   to: 'sessions3#create'
  delete '/super_admin_logout',  to: 'sessions3#destroy'
  resources :super_admins


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
