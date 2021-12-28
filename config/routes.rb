Rails.application.routes.draw do
  devise_for :admins, controllers: { sessions: 'admin/sessions', passwords: 'admin/passwords' }
  devise_for :sellers, controllers: { registrations: 'sellers/auth/registrations', sessions: 'sellers/auth/sessions', omniauth_callbacks: 'sellers/auth/omniauth', passwords: 'sellers/auth/passwords', unlocks: 'sellers/auth/unlocks'}
  devise_for :buyers, controllers: { registrations: 'buyers/auth/registrations', sessions: 'buyers/auth/sessions', passwords: 'buyers/auth/passwords' }

  devise_scope :admin do

    namespace :admin do
      root 'dashboard#index', as: :dashboard
      authenticated :admin do
        # root 'admin/dashboard#index', as: :admins_dashboard

        resources :orders, only: [:index, :show] do
          member do
            get :new_refund
            post :create_refund
            post :get_refund
          end
          collection do
            get :export_orders
          end
        end
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
            get :confirm_send_password_reset_email
            get :search
            post :send_password_reset_emails
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
          post :update_subscription_by_admin
          post :remove_seller_card
          post :renew_seller_subscription
          delete :remove_payout_bank_account
          get :verify_seller_stripe_account
          get :update_billing_listing
        end

        resources :categories do
          member do
            get :category_details
            get :category_products_with_pagination
            delete :remove_filter_group_association
            get :confirm_remove_filter_group_association
            delete :remove_image
            put :add_filter_group_association
            get :get_filter_groups
          end
          collection do
            get :search_category
            get :search_all_categories
            delete :category_products_delete_multiple
            get :manage_category_linking_filter
            get :gallery_images_with_pagination
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

        namespace :yavolos do
          resources :manual_bundles, except: %i[show new create edit] do
            collection do
              post :new, as: :new_manual_bundle
              post :edit, as: :edit_manual_bundle
              post :create_bundle, as: :create_manual_bundle
              put :update_bundle, as: :update_manual_bundle
              post :remove_product_bundle_association
              get :add_yavolos
              get :yavolo_product_details
              get :yavolo_least_stock_value
              delete :delete_yavolo
              get :export_yavolos
              get :bulk_max_stock_limit_value
              post :bulk_update_max_stock_limit
              post :publish_yavolo
            end
          end
        end

      end
    end
  end

  namespace :webhook do
    post :check_onboarding_status_webhook, :to => 'paypal_integrations#check_onboarding_status_webhook'
    post :subscription_start_webhook, :to => 'stripe_webhooks#subscription_start_webhook'
  end


  devise_scope :seller do
    unauthenticated :seller do
      get '/two_auth_new', :to => 'sellers/auth/sessions#two_auth_new'
      post '/two_auth_create', :to => 'sellers/auth/sessions#two_auth_create'
    end

    authenticated :seller do
      namespace :sellers do
        root to: 'dashboard#index', as: :seller_authenticated_root

        resources :payment_methods
        get :refresh_onboarding_link, :to => 'bank_accounts#refresh_onboarding_link'
        get :check_onboarding_status, :to => 'bank_accounts#check_onboarding_status'
        delete :remove_payout_bank_account, :to => 'bank_accounts#remove_payout_bank_account'
        get :set_default_card, :to => 'payment_methods#set_default_card'
        get :link_with_stripe, :to => 'payment_methods#link_with_stripe'
        post :add_bank_details, to: 'bank_accounts#add_bank_details'
        resources :paypal_integrations, only: %i[index]
        post :check_onboarding_status, :to => 'paypal_integrations#check_onboarding_status'
        resources :subscriptions, except: %i[index create new update edit show]
        get :create_stripe_subscription, :to => 'subscriptions#create_stripe_subscription'
        get :remove_subscription, :to => 'subscriptions#remove_subscription'
        get :get_current_subscription, :to => 'subscriptions#get_current_subscription'
        # get :bank_details, :to => 'bank_accounts#bank_details'
        # get :update_bank_account, :to => 'bank_accounts#update_bank_account'
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
          devise_scope :seller do
          end
          resources :sign_up_steps
        end
        resources :profiles do
          collection do
            post :manage_returns_and_terms
          end
          member do
            patch :seller_login_setting_update
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
            get :skip_success_hub_steps
            get :reviewed_login_screen
          end
          post :update_seller_api
          patch :update_seller_api
        end
        resource :connection_manager do
          get :confirm_update
        end
        resources :otp_secret

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
        resources :orders

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
    # post :check_onboarding_status_webhook, :to => 'sellers/paypal_integration#check_onboarding_status_webhook'
  end

  devise_scope :buyer do
    authenticated :buyer do
      namespace :buyers do
        root 'dashboard#index', as: :buyer_authenticated_root
      end
    end
  end

  put 'sellers/preview_listing', to: "sellers/products#preview_listing", as: :seller_preview_listing
  put 'admin/preview_listing', to: "admin/products#preview_listing", as: :admin_preview_listing
  get 'product/:id', to: "buyers/products#show", as: :product
  get 'store_front', to: "buyers/cart#store_front", as: :store_front
  post 'add_to_cart', to: "buyers/cart#add_to_cart", as: :add_to_cart
  # post 'update_product_quantity', to: "buyers/cart#update_product_quantity", as: :update_product_quantity
  post 'update_product_quantity_by_number', to: "buyers/cart#update_product_quantity_by_number", as: :update_product_quantity_by_number
  post 'update_selected_payment_method', to: "buyers/cart#update_selected_payment_method", as: :update_selected_payment_method
  get 'cart', to: "buyers/cart#cart", as: :cart
  delete 'remove_product_form_cart', to: 'buyers/cart#remove_product_form_cart', as: :remove_product_form_cart
  delete 'remove_product_from_summary', to: 'buyers/cart#remove_product_from_summary', as: :remove_product_from_summary
  
  get 'checkout', to: 'buyers/checkout#new', as: :checkout
  post 'create_checkout', to: 'buyers/checkout#create_checkout', as: :create_checkout
  get 'payment_method', to: 'buyers/checkout#payment_method', as: :payment_method
  get 'review_order', to: 'buyers/checkout#review_order', as: :review_order
  get 'order_completed', to: 'buyers/checkout#order_completed', as: :order_completed
  post 'create_payment_method', to: 'buyers/checkout#create_payment_method', as: :create_payment_method
  post 'create_payment', to: 'buyers/checkout#create_payment', as: :create_payment

  # acecpt google pay payment
  post 'create_google_payment', to: 'buyers/checkout#create_google_payment', as: :create_google_payment
  post 'confirm_google_pay_payment', to: 'buyers/checkout#confirm_google_pay_payment', as: :confirm_google_pay_payment

  post :create_paypal_order, to: 'buyers/checkout#create_paypal_order'
  post :capture_paypal_order, to: 'buyers/checkout#capture_paypal_order'

  post :paypal_payout_webhook, to: 'buyers/checkout#paypal_payout_webhook'

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
