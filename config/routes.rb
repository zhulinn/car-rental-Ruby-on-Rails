Rails.application.routes.draw do

  root 'sessions#new'

  resources :admins

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/signup', to: 'customers#new'

  resources :customers

  resources :admins

  resources :super_admins

  resources :records


  resources :cars do
    member do
      get 'schedule'
      post 'action'
      patch 'action'
      get 'beforecheckout'
      get 'subscribe'
     # get 'checkout'
      get 'return'
      post 'reserve'
      get 'cancel'
      get 'approve'
      get 'disapprove'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
