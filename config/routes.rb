Rails.application.routes.draw do
  root to: 'home#index'
  
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
end
