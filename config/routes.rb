Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: 'catalog#index', constraints:
    ->(_request) { CatalogController.blacklight_config.connection_config[:url].length > 10 }
  # See alternative bootstrap root at bottom of routes

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end
  devise_for :users

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

  resources :themes do
    patch 'activate', on: :member
  end
  resources :configs

  scope path: '/admin', module: :admin do
    resources :roles
    get :status, to: 'status#index'
  end

  # When app is firt booted and no Solr config exists, use this as the application root
  # We'll generally only need this route once or twice, so we're placing it at the bottom
  # of the route matchers
  root to: 'configs#new', as: :config_new_install, constraints:
    ->(_request) { CatalogController.blacklight_config.connection_config[:url].length < 11 }
end
