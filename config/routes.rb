Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: 'catalog#index', constraints:
    ->(_request) { CatalogController.blacklight_config.connection_config[:url].length > 10 }
  # See alternative bootstrap root at bottom of routes

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  scope path: '/admin', module: :admin do
    get :status, to: 'status#index'
    resources :users
    resources :roles
    resources :themes do
      patch 'activate', on: :member
    end
    resources :configs
  end

  # When app is firt booted and no Solr config exists, use this as the application root
  # We'll generally only need this route once or twice, so we're placing it at the bottom
  # of the route matchers
  root to: 'configs#new', as: :config_new_install, constraints:
    ->(_request) { CatalogController.blacklight_config.connection_config[:url].length < 11 }
end
