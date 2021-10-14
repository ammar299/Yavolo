Rails.application.routes.draw do
  devise_for :admins, controllers: { sessions: 'admin/sessions', passwords: 'admin/passwords' }
  devise_for :sellers, controllers: { registrations: 'sellers/auth/registrations', sessions: 'sellers/auth/sessions', omniauth_callbacks: 'sellers/auth/omniauth' }
  devise_for :buyers, controllers: { registrations: 'buyers/auth/registrations', sessions: 'buyers/auth/sessions' }

  devise_scope :admin do
    authenticated :admin do
      root 'admin/dashboard#index', as: :admins_dashboard
      namespace :admin do
        # root 'admin/dashboard#index', as: :admins_dashboard
        root 'dashboard#index', as: :dashboard
        resources :delivery_options, except: %i[show] do
          collection do
            delete :delete_delivery_options
          end
        end

        resources :sellers do
          collection do
            get :update_multiple
          end
        end
        resources :categories

        resources :carriers, except: %i[index show] do
          collection do
            delete :delete_carriers
          end
        end

        resources :delivery_options, except: %i[show] do
          collection do
            delete :delete_delivery_options
          end
        end

        resources :products do
          collection do
            get 'duplicate'
          end
        end

        resources :filter_groups do
          collection do
            delete 'destroy_multiple'
          end
        end
      end
    end
  end


  devise_scope :seller do
    authenticated :seller do
      namespace :sellers do
        root 'dashboard#index', as: :seller_authenticated_root
      end
    end
  end

  devise_scope :buyer do
    authenticated :buyer do
      namespace :buyers do
        root 'dashboard#index', as: :buyer_authenticated_root
      end
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



  get '*path', to: redirect('/'), constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
