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
            get    :search_seller_delivery_options
          end
          member do
            get :confirm_delete
            delete :delete_delivery_option
          end
        end
        get 'export_sellers', to: 'sellers#export_sellers', as: :export_sellers
        post 'import_sellers', to: 'sellers#import_sellers', as: :import_sellers
        resources :sellers do
          collection do
            get :update_multiple
            get :confirm_multi_update
            get :search
          end
          member do
            patch :update_business_representative
            patch :update_company_detail
            patch :update_addresses
            patch :update_seller_logo
            delete :remove_logo_image
            get :confirm_update_seller
            patch :update_seller
            get :new_seller_api
            post :create_seller_api
            get :confirm_update_seller_api
            patch :update_seller_api
            get :confirm_change_seller_api_eligibility
            patch :change_seller_api_eligibility
            get :confirm_lock_status
            patch :change_lock_status
            patch :holiday_mode
            get :confirm_reset_password_token
            patch :reset_password_token
          end
          post :update_seller_api
          patch :update_seller_api
        end

        resources :categories do
          member do
            get :category_details
            get :category_products_with_pagination
            delete :remove_filter_group_association
            delete :remove_image
            put :add_filter_group_association
            get :get_filter_groups
          end
          collection do
            get :search_category
            delete :category_products_delete_multiple
            get :manage_category_linking_filter
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
            get :duplicate
            post :upload_csv
            get :export_csv
            post :bulk_products_update
            post :enable_yavolo
            post :disable_yavolo
          end
        end

        resources :filter_groups do
          collection do
            get    :confirm_multiple_deletion
            get    :assign_category
            put    :create_assign_category
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
        resources :paypal_integration, only: %i[index]
        post :check_onboarding_status, :to => 'paypal_integration#check_onboarding_status'
        resources :delivery_options, except: %i[show] do
          collection do
            get    :confirm_multiple_deletion
            delete :delete_delivery_options
          end
          member do
            get :confirm_delete
          end
        end
        namespace :auth do 
          resources :sign_up_steps
        end
        resources :profiles do
          collection do
            post :manage_returns_and_terms
          end
          member do
            patch :update_business_representative
            patch :update_company_detail
            patch :update_addresses
            patch :update_seller_logo
            delete :remove_logo_image
            get :confirm_delete
            get :confirm_refresh_api
            get :search_delivery_options
            delete :destroy_delivery_template
            patch :holiday_mode
            get :confirm_reset_password_token
            patch :reset_password_token
          end
          post :update_seller_api
          patch :update_seller_api
        end
        resource :connection_manager do
          get :confirm_update
        end
        root to: 'dashboard#index', as: :seller_authenticated_root

        resources :products do
          collection do
            get :duplicate
            post :upload_csv
            get :export_csv
            post :enable_yavolo
            post :disable_yavolo
            post :bulk_products_update
          end
          member do
            post :update_field
          end
        end

        resources :categories do
          member do
            get :get_filter_groups
          end
          collection do
            get :search_category
          end
        end

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

  get 'product/:id', to: "buyers/products#show", as: :product
  get 'store_front', to: "buyers/cart#store_front", as: :store_front
  post 'add_to_cart', to: "buyers/cart#add_to_cart", as: :add_to_cart
  post 'update_product_quantity', to: "buyers/cart#update_product_quantity", as: :update_product_quantity
  post 'update_product_quantity_by_number', to: "buyers/cart#update_product_quantity_by_number", as: :update_product_quantity_by_number
  get 'cart', to: "buyers/cart#cart", as: :cart
  delete 'remove_product_form_cart', to: 'buyers/cart#remove_product_form_cart', as: :remove_product_form_cart

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
