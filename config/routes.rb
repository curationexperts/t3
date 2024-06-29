Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: 'catalog#index', constraints:
    ->(_request) { CatalogController.blacklight_config.connection_config[:url].length > 10 }
  # See alternative bootstrap root at bottom of routes

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks',
                                    invitations: 'users/invitations' }

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
    resources :ingests
    resources :items do
      get 'new/:blueprint', on: :collection, action: :new, as: :new_blueprinted
    end
    resources :collections do
      get 'new/:blueprint', on: :collection, action: :new, as: :new_blueprinted
    end
    resources :users
    resources :roles
    resources :blueprints
    resources :fields do
      patch 'move', on: :member
    end
    resources :vocabularies, param: :slug do
      resources :terms, param: :slug
    end
    resources :themes do
      patch 'activate', on: :member
    end
    resources :custom_domains, except: %i[edit update show]
    get 'profile', to: 'users#edit', as: :edit_user_registration
    post 'users/:id/password_reset', to: 'users#password_reset', as: :user_password_reset
    resource :config, only: %i[show edit update]
  end
  resolve('Config') { [:config] }

  direct :term do |term|
    if term.slug
      { controller: 'admin/terms', action: :show, vocabulary_slug: term.vocabulary.slug, slug: term.slug }
    else
      { controller: 'admin/terms', vocabulary_slug: term.vocabulary }
    end
  end
  direct :edit_term do |term|
    { controller: 'admin/terms', action: :edit, vocabulary_slug: term.vocabulary.slug, slug: term.slug }
  end
  direct :terms do |term|
    { controller: 'admin/terms', vocabulary_slug: term.vocabulary }
  end

  # When app is firt booted and no Solr config exists, use this as the application root
  # We'll generally only need this route once or twice, so we're placing it at the bottom
  # of the route matchers
  root to: 'configs#new', as: :config_new_install, constraints:
    ->(_request) { CatalogController.blacklight_config.connection_config[:url].length < 11 }
end
