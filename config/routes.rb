Rails.application.routes.draw do
  devise_for :admins, controllers: { sessions: 'admin/sessions' }
  devise_for :sellers, controllers: { registrations: 'sellers/auth/registrations', sessions: 'sellers/auth/sessions', omniauth_callbacks: 'sellers/auth/omniauth' }
  devise_for :buyers, controllers: { registrations: 'buyers/auth/registrations', sessions: 'buyers/auth/sessions' }

  devise_scope :admin do
    authenticated :admin do
      root 'admin/dashboard#index', as: :admins_dashboard
    end
  end


  devise_scope :seller do
    authenticated :seller do
      namespace :sellers do
        # namespace :dashboard do
        # end
        root 'dashboard/seller_dashboard#index', as: :seller_authenticated_root
      end
      # root 'sellers/dashboard/seller_dashboard#index', as: :seller_authenticated_root
    end
  end

  devise_scope :buyer do
    authenticated :buyer do
      namespace :buyers do
        # namespace :dashboard do
        # end
        root 'dashboard/buyer_dashboard#index', as: :buyer_authenticated_root
      end
      # root 'buyers/dashboard/buyer_dashboard#index', as: :buyer_authenticated_root
    end
  end

  resource :user, only: :update
  get :profile, to: 'users#show'
  scope :profile do
    get :edit, to: 'users#edit', as: :profile_edit
    get 'password/edit', to: 'users#edit_password', as: :edit_password
    patch 'password/update', to: 'users#update_password', as: :update_password
  end

  root to: 'home#index'
  get '/demo/signin', to: 'home#signin'
  get '/demo/signup', to: 'home#signup'
  # get '*path', to: 'home#index', via: :all


  get '/sellers/dashboard/seller_dashboard', to: 'sellers/dashboard/seller_dashboard#index', as: :sellers_dashboard
  get '/buyers/dashboard/buyer_dashboard', to: 'buyers/dashboard/buyer_dashboard#index', as: :buyers_dashboard

  get '*path', to: redirect('/'), constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
