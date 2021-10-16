Rails.application.routes.draw do
  devise_for :admins, controllers: { sessions: 'admin/sessions', passwords: 'admin/passwords' }
  devise_for :sellers, controllers: { registrations: 'sellers/auth/registrations', sessions: 'sellers/auth/sessions', omniauth_callbacks: 'sellers/auth/omniauth', passwords: 'sellers/auth/passwords'}
  devise_for :buyers, controllers: { registrations: 'buyers/auth/registrations', sessions: 'buyers/auth/sessions', passwords: 'buyers/auth/passwords' }

  devise_scope :admin do
    authenticated :admin do
      root 'admin/dashboard#index', as: :admins_dashboard
      namespace :admin do
        # root 'admin/dashboard#index', as: :admins_dashboard
        root 'dashboard#index', as: :dashboard
        resources :delivery_options, except: %i[show] do
          collection do
            get    :confirm_multiple_deletion
            delete :delete_delivery_options
          end
          member do
            get :confirm_delete
          end
        end

        resources :sellers do
          collection do
            get :update_multiple
          end
          member do
            patch :update_business_representative
            patch :update_company_detail
            patch :update_addresses
            patch :update_seller_logo
            delete :remove_logo_image
          end
          post :update_seller_api
          post :refresh_seller_api
          patch :update_seller_api
        end

        resources :categories do
          member do
            get :category_details
            delete :remove_filter_group_association
            delete :remove_image
            put :add_filter_group_association
          end
        end

        resources :carriers, except: %i[index show] do
          collection do
            get    :confirm_multiple_deletion
            delete :delete_carriers
          end
          member do
            get :confirm_delete
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
            post 'upload_csv'
          end
        end

        resources :filter_groups do
          collection do
            get    :confirm_multiple_deletion
            delete :delete_filter_groups
          end
          member do
            get :confirm_delete
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

  root to: 'buyers/dashboard#index'



  get '*path', to: redirect('/'), constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end
