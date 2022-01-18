# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_12_115135) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.string "phone_number"
    t.integer "address_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "addressable_id"
    t.string "addressable_type"
    t.index ["addressable_id"], name: "index_addresses_on_addressable_id"
    t.index ["addressable_type"], name: "index_addresses_on_addressable_type"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "assigned_categories", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_assigned_categories_on_category_id"
    t.index ["product_id"], name: "index_assigned_categories_on_product_id"
  end

  create_table "automatic_bundling_last_runs", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bank_details", force: :cascade do |t|
    t.string "currency"
    t.string "country"
    t.string "sort_code"
    t.string "account_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "seller_id"
    t.string "account_holder_name"
    t.string "account_holder_type"
    t.string "customer_stripe_account_id"
    t.string "account_verification_status"
    t.string "requirements"
    t.string "available_payout_methods"
    t.string "bank_name"
    t.string "last4"
    t.string "fingerprint"
    t.string "onboarding_link"
    t.string "stripe_account_type"
    t.index ["seller_id"], name: "index_bank_details_on_seller_id"
  end

  create_table "billing_addresses", force: :cascade do |t|
    t.string "appartment"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.index ["order_id"], name: "index_billing_addresses_on_order_id"
  end

  create_table "billing_listing_stripes", force: :cascade do |t|
    t.string "invoice_id"
    t.float "total"
    t.string "description"
    t.datetime "date_generated"
    t.datetime "due_date"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "seller_id"
    t.index ["seller_id"], name: "index_billing_listing_stripes_on_seller_id"
  end

  create_table "business_representatives", force: :cascade do |t|
    t.string "email"
    t.string "job_title"
    t.date "date_of_birth"
    t.string "contact_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "seller_id"
    t.string "full_legal_name", default: ""
    t.index ["email"], name: "index_business_representatives_on_email"
    t.index ["seller_id"], name: "index_business_representatives_on_seller_id"
  end

  create_table "buyer_payment_methods", force: :cascade do |t|
    t.string "token"
    t.string "last_digits"
    t.string "card_holder_name"
    t.string "card_id"
    t.bigint "buyer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "brand"
    t.integer "exp_month"
    t.integer "exp_year"
    t.integer "payment_method_type"
    t.boolean "is_card_saved", default: false
    t.index ["buyer_id"], name: "index_buyer_payment_methods_on_buyer_id"
  end

  create_table "buyers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "surname"
    t.integer "gender"
    t.date "date_of_birth"
    t.string "contact_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "receive_deals_via_email", default: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_buyers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_buyers_on_reset_password_token", unique: true
  end

  create_table "carriers", force: :cascade do |t|
    t.string "name"
    t.string "api_key"
    t.string "secret_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "category_name"
    t.boolean "baby_category", default: false
    t.string "category_description"
    t.string "bundle_label"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.string "category_id_string"
    t.string "url"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
  end

  create_table "category_excluded_filter_groups", force: :cascade do |t|
    t.integer "filter_group_id"
    t.integer "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "company_details", force: :cascade do |t|
    t.string "name"
    t.string "vat_number"
    t.string "country"
    t.string "legal_business_name"
    t.string "companies_house_registration_number"
    t.string "business_industry"
    t.string "business_phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "seller_id"
    t.string "website_url", default: ""
    t.string "amazon_url", default: ""
    t.string "ebay_url", default: ""
    t.string "doing_business_as", default: ""
    t.string "first_name"
    t.string "last_name"
    t.index ["seller_id"], name: "index_company_details_on_seller_id"
  end

  create_table "csv_imports", force: :cascade do |t|
    t.string "file"
    t.bigint "importer_id"
    t.string "importer_type"
    t.integer "status"
    t.text "import_errors"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "title_list"
    t.index ["importer_type", "importer_id"], name: "index_csv_imports_on_importer_type_and_importer_id"
  end

  create_table "delivery_option_ships", force: :cascade do |t|
    t.decimal "price", precision: 8, scale: 2
    t.bigint "delivery_option_id"
    t.bigint "ship_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "processing_time"
    t.integer "delivery_time"
    t.index ["delivery_option_id"], name: "index_delivery_option_ships_on_delivery_option_id"
    t.index ["ship_id"], name: "index_delivery_option_ships_on_ship_id"
  end

  create_table "delivery_options", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "delivery_optionable_type"
    t.bigint "delivery_optionable_id"
    t.string "handle"
    t.index ["delivery_optionable_type", "delivery_optionable_id"], name: "index_delivery_options_on_delivery_optionable"
  end

  create_table "ebay_details", force: :cascade do |t|
    t.decimal "lifetime_sales", precision: 10, scale: 2
    t.decimal "thirty_day_sales", precision: 10, scale: 2
    t.decimal "price", precision: 8, scale: 2
    t.decimal "thirty_day_revenue", precision: 10, scale: 2
    t.string "mpn_number"
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_ebay_details_on_product_id"
  end

  create_table "fav_products", force: :cascade do |t|
    t.bigint "wishlist_id"
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_fav_products_on_product_id"
    t.index ["wishlist_id"], name: "index_fav_products_on_wishlist_id"
  end

  create_table "filter_categories", force: :cascade do |t|
    t.integer "filter_group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "category_id"
    t.index ["filter_group_id"], name: "index_filter_categories_on_filter_group_id"
  end

  create_table "filter_groups", force: :cascade do |t|
    t.string "name"
    t.integer "filter_group_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_filter_groups_on_name"
  end

  create_table "filter_in_categories", force: :cascade do |t|
    t.string "filter_name"
    t.integer "sort_order"
    t.integer "filter_group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "category_id"
    t.index ["filter_group_id"], name: "index_filter_in_categories_on_filter_group_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "google_shoppings", force: :cascade do |t|
    t.string "title"
    t.decimal "price", precision: 8, scale: 2
    t.string "category"
    t.string "campaign_category"
    t.text "description"
    t.bigint "google_shopping_able_id"
    t.boolean "exclude_from_google_feed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "google_shopping_able_type"
    t.index ["google_shopping_able_id"], name: "index_google_shoppings_on_google_shopping_able_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.bigint "product_id"
    t.decimal "price"
    t.string "added_on"
    t.integer "quantity"
    t.string "transfer_id"
    t.integer "transfer_status"
    t.decimal "commission"
    t.decimal "remaining_price"
    t.decimal "refunded_amount"
    t.integer "commission_status", default: 0
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
  end

  create_table "linking_filters", force: :cascade do |t|
    t.integer "filter_in_category_id"
    t.integer "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "meta_contents", force: :cascade do |t|
    t.string "title"
    t.text "keywords"
    t.text "description"
    t.string "url"
    t.string "meta_able_type"
    t.bigint "meta_able_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meta_able_type", "meta_able_id"], name: "index_meta_contents_on_meta_able"
  end

  create_table "order_details", force: :cascade do |t|
    t.string "first_name"
    t.string "email"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.string "last_name"
    t.string "full_name"
    t.index ["order_id"], name: "index_order_details_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "order_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "sub_total"
    t.integer "discount_percentage"
    t.decimal "discounted_price"
    t.bigint "buyer_id"
    t.bigint "buyer_payment_method_id"
    t.float "total"
    t.string "order_number"
    t.boolean "billing_address_is_shipping_address", default: false
    t.decimal "commission"
    t.decimal "remaining_price"
    t.decimal "refunded_amount"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["buyer_payment_method_id"], name: "index_orders_on_buyer_payment_method_id"
  end

  create_table "payment_modes", force: :cascade do |t|
    t.integer "payment_through"
    t.string "charge_id"
    t.integer "amount"
    t.string "return_url"
    t.string "receipt_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.index ["order_id"], name: "index_payment_modes_on_order_id"
  end

  create_table "paypal_details", force: :cascade do |t|
    t.boolean "integration_status"
    t.string "seller_merchant_id_in_paypal"
    t.string "seller_client_id"
    t.string "seller_action_url"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["seller_id"], name: "index_paypal_details_on_seller_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "pictures", force: :cascade do |t|
    t.string "name"
    t.bigint "imageable_id"
    t.string "imageable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_featured", default: false
    t.index ["imageable_type", "imageable_id"], name: "index_pictures_on_imageable_type_and_imageable_id"
  end

  create_table "product_assignment_settings", force: :cascade do |t|
    t.decimal "price", precision: 8, scale: 2
    t.integer "items"
    t.integer "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "product_assignments", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "priority"
    t.bigint "total_sales"
    t.decimal "total_revenue", precision: 18, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_product_assignments_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.text "description"
    t.text "keywords"
    t.string "sku"
    t.string "ean"
    t.string "yan"
    t.string "brand"
    t.integer "condition"
    t.integer "status"
    t.integer "stock"
    t.decimal "price", precision: 9, scale: 2
    t.decimal "discount", precision: 8, scale: 2
    t.integer "discount_unit"
    t.boolean "yavolo_enabled", default: false
    t.string "width"
    t.string "depth"
    t.string "height"
    t.string "colour"
    t.string "material"
    t.datetime "published_at"
    t.bigint "owner_id"
    t.string "owner_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "delivery_option_id"
    t.text "filter_in_category_ids"
    t.index ["brand"], name: "index_products_on_brand"
    t.index ["delivery_option_id"], name: "index_products_on_delivery_option_id"
    t.index ["ean"], name: "index_products_on_ean"
    t.index ["handle"], name: "index_products_on_handle", unique: true
    t.index ["owner_type", "owner_id"], name: "index_products_on_owner_type_and_owner_id"
    t.index ["price"], name: "index_products_on_price"
    t.index ["sku"], name: "index_products_on_sku"
    t.index ["status"], name: "index_products_on_status"
    t.index ["title"], name: "index_products_on_title"
    t.index ["yan"], name: "index_products_on_yan"
  end

  create_table "refund_details", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "refund_id"
    t.decimal "amount_refund"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "line_item_id"
    t.index ["line_item_id"], name: "index_refund_details_on_line_item_id"
    t.index ["order_id"], name: "index_refund_details_on_order_id"
    t.index ["refund_id"], name: "index_refund_details_on_refund_id"
  end

  create_table "refund_modes", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "refund_id"
    t.bigint "buyer_id"
    t.bigint "line_item_id"
    t.string "response_refund_id"
    t.string "charge_id"
    t.decimal "amount_refund"
    t.integer "refund_through"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_id"], name: "index_refund_modes_on_buyer_id"
    t.index ["line_item_id"], name: "index_refund_modes_on_line_item_id"
    t.index ["order_id"], name: "index_refund_modes_on_order_id"
    t.index ["refund_id"], name: "index_refund_modes_on_refund_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.bigint "order_id"
    t.integer "refund_reason"
    t.decimal "total_paid"
    t.decimal "total_refund"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_refunds_on_order_id"
  end

  create_table "return_and_terms", force: :cascade do |t|
    t.integer "duration"
    t.boolean "email_format", default: false
    t.boolean "authorisation_and_prepaid", default: false
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "instructions"
    t.index ["seller_id"], name: "index_return_and_terms_on_seller_id"
  end

  create_table "reversal_modes", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "refund_id"
    t.bigint "seller_id"
    t.bigint "line_item_id"
    t.string "transfer_id"
    t.string "transfer_reversal_id"
    t.integer "reversal_through"
    t.decimal "amount_reversed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_item_id"], name: "index_reversal_modes_on_line_item_id"
    t.index ["order_id"], name: "index_reversal_modes_on_order_id"
    t.index ["refund_id"], name: "index_reversal_modes_on_refund_id"
    t.index ["seller_id"], name: "index_reversal_modes_on_seller_id"
  end

  create_table "seller_apis", force: :cascade do |t|
    t.string "name"
    t.string "api_token"
    t.integer "status"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "developer_name"
    t.string "developer_id"
    t.string "app_name"
    t.datetime "expiry_date"
    t.index ["seller_id"], name: "index_seller_apis_on_seller_id"
  end

  create_table "seller_payment_methods", force: :cascade do |t|
    t.string "stripe_token"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "last_digits"
    t.string "card_holder_name"
    t.string "payment_terms"
    t.boolean "default_status"
    t.string "card_id"
    t.index ["seller_id"], name: "index_seller_payment_methods_on_seller_id"
  end

  create_table "seller_stripe_subscriptions", force: :cascade do |t|
    t.string "subscription_stripe_id"
    t.string "plan_name"
    t.string "status"
    t.string "product_id"
    t.datetime "cancel_at"
    t.boolean "cancel_at_period_end"
    t.datetime "canceled_at"
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.string "customer"
    t.integer "recurring_interval_count"
    t.string "recurring_interval"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "subscription_schedule_id"
    t.boolean "seller_requested_cancelation", default: false
    t.string "status_set_by_admin"
    t.datetime "schedule_date"
    t.string "plan_id"
    t.boolean "cancel_after_next_payment_taken", default: false
    t.string "subscription_data"
    t.string "associated_worker"
    t.string "reason"
    t.index ["seller_id"], name: "index_seller_stripe_subscriptions_on_seller_id"
  end

  create_table "sellers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "surname"
    t.integer "gender"
    t.date "date_of_birth"
    t.string "contact_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.integer "account_status", default: 0
    t.integer "listing_status", default: 0
    t.string "contact_email", default: "", null: false
    t.string "contact_name", default: "", null: false
    t.string "subscription_type", default: "0"
    t.boolean "terms_and_conditions", default: false
    t.boolean "recieve_deals_via_email", default: false
    t.boolean "multistep_sign_up", default: true
    t.boolean "eligible_to_create_api", default: false
    t.boolean "holiday_mode", default: false
    t.boolean "is_locked", default: false
    t.integer "timeout"
    t.boolean "two_factor_auth", default: false
    t.datetime "last_seen_at"
    t.string "recovery_email"
    t.string "otp_secret"
    t.integer "last_otp_at"
    t.boolean "skip_success_hub_steps", default: false
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "reviewed_login_screen", default: false
    t.string "full_name"
    t.index ["email"], name: "index_sellers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_sellers_on_reset_password_token", unique: true
  end

  create_table "seo_contents", force: :cascade do |t|
    t.string "title"
    t.text "url"
    t.text "description"
    t.text "keywords"
    t.bigint "seo_content_able_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "seo_content_able_type"
    t.index ["seo_content_able_id"], name: "index_seo_contents_on_seo_content_able_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shipping_addresses", force: :cascade do |t|
    t.string "appartment"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "county"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.index ["order_id"], name: "index_shipping_addresses_on_order_id"
  end

  create_table "ships", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stripe_customers", force: :cascade do |t|
    t.string "customer_id"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "stripe_customerable_id"
    t.string "stripe_customerable_type"
    t.index ["stripe_customerable_id"], name: "index_stripe_customers_on_stripe_customerable_id"
    t.index ["stripe_customerable_type"], name: "index_stripe_customers_on_stripe_customerable_type"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "subscription_name"
    t.string "subscription_type"
    t.float "price"
    t.float "commission_excluding_vat"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "subscription_months"
    t.string "rolling_subscription"
    t.boolean "default_subscription", default: false
    t.string "plan_id"
    t.string "plan_name_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "surname"
    t.integer "role"
    t.boolean "receive_best_deals", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "buyer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_id"], name: "index_wishlists_on_buyer_id"
  end

  create_table "yavolo_bundle_products", force: :cascade do |t|
    t.decimal "price", precision: 9, scale: 2
    t.bigint "product_id", null: false
    t.bigint "yavolo_bundle_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_yavolo_bundle_products_on_product_id"
    t.index ["yavolo_bundle_id"], name: "index_yavolo_bundle_products_on_yavolo_bundle_id"
  end

  create_table "yavolo_bundles", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.text "description"
    t.bigint "category_id"
    t.integer "status"
    t.string "yan"
    t.integer "quantity"
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "stock_limit"
    t.integer "max_stock_limit"
    t.decimal "regular_total", precision: 8, scale: 2
    t.decimal "yavolo_total", precision: 8, scale: 2
    t.integer "previous_status"
    t.index ["category_id"], name: "index_yavolo_bundles_on_category_id"
    t.index ["status"], name: "index_yavolo_bundles_on_status"
    t.index ["title"], name: "index_yavolo_bundles_on_title"
    t.index ["yan"], name: "index_yavolo_bundles_on_yan"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "billing_listing_stripes", "sellers"
  add_foreign_key "delivery_option_ships", "delivery_options"
  add_foreign_key "delivery_option_ships", "ships"
  add_foreign_key "fav_products", "products"
  add_foreign_key "fav_products", "wishlists"
  add_foreign_key "paypal_details", "sellers"
  add_foreign_key "product_assignments", "products"
  add_foreign_key "refund_details", "orders"
  add_foreign_key "refund_details", "refunds"
  add_foreign_key "refund_modes", "buyers"
  add_foreign_key "refund_modes", "line_items"
  add_foreign_key "refund_modes", "orders"
  add_foreign_key "refund_modes", "refunds"
  add_foreign_key "refunds", "orders"
  add_foreign_key "return_and_terms", "sellers"
  add_foreign_key "reversal_modes", "line_items"
  add_foreign_key "reversal_modes", "orders"
  add_foreign_key "reversal_modes", "refunds"
  add_foreign_key "reversal_modes", "sellers"
  add_foreign_key "seller_apis", "sellers"
  add_foreign_key "seller_payment_methods", "sellers"
  add_foreign_key "seller_stripe_subscriptions", "sellers"
  add_foreign_key "wishlists", "buyers"
  add_foreign_key "yavolo_bundle_products", "products"
  add_foreign_key "yavolo_bundle_products", "yavolo_bundles"
end
