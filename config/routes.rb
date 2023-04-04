Rails.application.routes.draw do
  resources :blueprints do
    resources :fields, shallow: true
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
