require 'sidekiq/web'
PragueServer::Application.routes.draw do
  devise_for :users, controllers: { registrations: :users, confirmations: :confirmations }

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end

  ActiveAdmin.routes(self)
  get 'config/:id', to: ConfigController.action(:index)

  namespace :api do
    resources :namespaces, controller: 'namespaces', only: [:index, :show] do
      collection do
        get :raised
      end

      member do
        get :history
      end

      resources :charges, only: [:index], controller: 'namespaces/charges'
    end
    resources :tags, controller: 'tags', only: [:index, :show] do
      member do
        get :history
      end
      resources :charges, only: [:index], controller: 'tags/charges'
    end
    resources :charges, controller: 'charges', only: [:index]
    resource :config, controller: 'config', only: [:show]
    resource :code_snippet, controller: 'code_snippet', only: [:show] do
      member do
        get 'parameters'
      end
    end
  end

  resources :orgs, only: [:show, :new, :create, :update], controller: 'organizations', :as => 'organizations' do
    member do
      patch 'toggle'
      put 'deauthorize'
    end
    resource  :settings, only: [:show], controller: 'org/settings'
    resources :crms, only: [:create, :update], controller: 'org/crms'
    resources :invitations, only: [:create], controller: 'org/invitations'
    resources :users, controller: 'org/users'
    resources :charges, controller: 'org/charges'
    resources :tags, controller: 'org/tags' do
      resources :charges, only: [:index], controller: 'org/tags/charges'
    end
    resources :namespaces, controller: 'org/namespaces' do
      collection do
        get :raised
      end
    end
  end

  resources :charges, only: [:create, :destroy]

  get '/auth/:provider/callback', to: 'authentications#create'

  root 'home#index'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount StripeEvent::Engine => '/stripe/event'

end
