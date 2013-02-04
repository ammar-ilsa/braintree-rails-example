BraintreeRailsExample::Application.routes.draw do
  resources :users do
    resource :customer do
      resources :credit_cards do
        resources :transactions, :except => [:edit, :destroy]
        resources :plans
      end
      resources :addresses
      resources :transactions, :except => [:edit, :destroy]
      resources :plans
    end
  end
  resources :transactions, :except => [:edit, :destroy]
  resources :plans
  root :to => 'users#index'
end
