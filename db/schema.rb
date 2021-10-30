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

ActiveRecord::Schema.define(version: 2021_10_29_064002) do

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
    t.bigint "seller_id"
    t.index ["seller_id"], name: "index_addresses_on_seller_id"
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

  create_table "bank_details", force: :cascade do |t|
    t.string "currency"
    t.string "country"
    t.string "sort_code"
    t.string "account_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "seller_id"
    t.index ["seller_id"], name: "index_bank_details_on_seller_id"
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
    t.index ["importer_type", "importer_id"], name: "index_csv_imports_on_importer_type_and_importer_id"
  end

  create_table "delivery_option_ships", force: :cascade do |t|
    t.float "price"
    t.bigint "delivery_option_id"
    t.bigint "ship_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_option_id"], name: "index_delivery_option_ships_on_delivery_option_id"
    t.index ["ship_id"], name: "index_delivery_option_ships_on_ship_id"
  end

  create_table "delivery_options", force: :cascade do |t|
    t.string "name"
    t.integer "processing_time"
    t.integer "delivery_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "delivery_optionable_type"
    t.bigint "delivery_optionable_id"
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
    t.bigint "product_id"
    t.boolean "exclude_from_google_feed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_google_shoppings_on_product_id"
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
    t.index ["imageable_type", "imageable_id"], name: "index_pictures_on_imageable_type_and_imageable_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.string "handle"
    t.text "description"
    t.text "keywords"
    t.string "sku", null: false
    t.string "ean"
    t.string "yan"
    t.string "brand"
    t.integer "condition"
    t.integer "status"
    t.integer "stock"
    t.decimal "price", precision: 8, scale: 2
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

  create_table "seller_apis", force: :cascade do |t|
    t.string "name"
    t.string "api_token"
    t.integer "status"
    t.bigint "seller_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["seller_id"], name: "index_seller_apis_on_seller_id"
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
    t.integer "subscription_type", default: 0
    t.boolean "terms_and_conditions", default: false
    t.boolean "recieve_deals_via_email", default: false
    t.boolean "multistep_sign_up", default: true
    t.boolean "eligible_to_create_api", default: false
    t.boolean "holiday_mode", default: false
    t.boolean "is_locked", default: false
    t.index ["email"], name: "index_sellers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_sellers_on_reset_password_token", unique: true
  end

  create_table "seo_contents", force: :cascade do |t|
    t.string "title"
    t.text "url"
    t.text "description"
    t.text "keywords"
    t.bigint "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_seo_contents_on_product_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "ships", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "delivery_option_ships", "delivery_options"
  add_foreign_key "delivery_option_ships", "ships"
  add_foreign_key "paypal_details", "sellers"
  add_foreign_key "return_and_terms", "sellers"
  add_foreign_key "seller_apis", "sellers"
end
