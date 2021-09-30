Rails.application.routes.draw do
  
  # namespace :sellers do
  #   devise_for :sellers
  # end
  # devise_for :sellers
  devise_for :sellers, controllers: { registrations: 'sellers/registrations', sessions: 'sellers/sessions' }
  devise_for :buyers, controllers: { registrations: 'buyers/registrations', sessions: 'buyers/sessions' }

  devise_scope :seller do
    authenticated :seller do
      root 'seller_dashboard#index', as: :seller_dashboard
    end
  end

  devise_scope :buyer do
    authenticated :buyer do
      root 'buyer_dashboard#index', as: :buyer_dashboard
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: 'registrations', omniauth_callbacks: 'users/omniauth' }

  resource :user, only: :update
  get :profile, to: 'users#show'
  scope :profile do
    get :edit, to: 'users#edit', as: :profile_edit
    get 'password/edit', to: 'users#edit_password', as: :edit_password
    patch 'password/update', to: 'users#update_password', as: :update_password
  end

  # authenticate :user, ->(u) { u.buyer? } do
  #   get '/home', to: 'buyer_dashboard#index', as: :buyers_dashboard
  # end

  # authenticate :user, ->(u) { u.seller? } do
  #   get '/dashboard', to: 'seller_dashboard#index', as: :sellers_dashboard
  # end

  root to: 'home#index'
  get '/demo/signin', to: 'home#signin'
  get '/demo/signup', to: 'home#signup'
  # get '*path', to: 'home#index', via: :all

  get '*path', to: redirect('/'), constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
