module Products
  class Importer < ApplicationService
    require 'csv'
    attr_reader :status, :errors, :title_list, :existing_product_list, :params

    def initialize(params)
        @params = params
        @status = true
        @errors = []
        @title_list = []
        @existing_product_list = []
    end

    def call
      begin
        import_products_from_csv
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

      def import_products_from_csv
        file_path = "#{Rails.root}/public/#{csv_import.file.url}"
        csv_file_conent = File.read(file_path)
        csv = CSV.parse(csv_file_conent, :headers => true)
        csv_import.update({status: :importing})
        csv.each do |row|
          if have_required_fields?(row)
            params = get_params(row)
            seo_content = SeoContent.find_by(title: params[:seo_content_attributes][:title], description: params[:seo_content_attributes][:description])
            if seo_content.present?
              @existing_product_list << params[:title]
              next
            end
            product = Product.new(params)
            product.owner_id = product_owner_id(row)
            product.owner_type = product_owner_type(row)
            product.status = 'draft'
            product.filter_in_category_ids = []
            product.delivery_option_id = get_default_delivery_option_id
            if product.valid?
              product.save
            else
              @errors << "#{product.title}: #{product.errors.full_messages.join("<br>")}"
              @title_list << product.title
            end
          else
            @errors << "Required columns are missing"
            @title_list << product.title
            next
          end
        end
        @errors.present? ? csv_import.update(status: :failed, import_errors: @errors.uniq.join(', '), title_list: @title_list) : csv_import.update({status: :imported, existing_product_list: @existing_product_list})
        @errors.present? ? @status = false : @status = true
        # TODO: 'remove khawar work after testing' csv upload email work
        # csv_import.update(import_errors: @errors.uniq.join(', '), title_list: @title_list, existing_product_list: @existing_product_list )
        self
      end

      def product_owner_id(row)
        if row["seller"] != "Admin"
          owner = Seller.where("CONCAT_WS(' ', first_name, last_name) LIKE ?", row["seller"]).first
          if owner.present?
            return owner.id 
          else
            return nil
          end
        else
          return 1
        end
      end

      def product_owner_type(row)
        if row["seller"] != "Admin"
          return "Seller" 
        else
          return "Admin"
        end
      end

      def csv_import
        @csv_import ||= params[:csv_import]
      end

      def field_mappings
        @field_mappings ||= {
          # product
          'title'=>{ field: 'title', parent: 'product' },
          'condition'=>{ field: 'condition', parent: 'product' },
          'width'=> { field: 'width', parent: 'product' }, 
          'depth'=> { field: 'depth', parent: 'product' }, 
          'height'=> { field: 'height', parent: 'product' }, 
          'colour'=> { field: 'colour', parent: 'product' }, 
          'material'=> { field: 'material', parent: 'product' }, 
          'brand'=> { field: 'brand', parent: 'product' }, 
          'keywords'=> { field: 'keywords', parent: 'product' }, 
          'description'=> { field: 'description', parent: 'product' }, 
          'price'=> { field: 'price', parent: 'product' }, 
          'stock'=> { field: 'stock', parent: 'product' }, 
          'sku'=> { field: 'sku', parent: 'product' }, 
          'ean'=> { field: 'ean', parent: 'product' }, 
          'discount'=> { field: 'discount', parent: 'product' }, 
          'yavolo_enabled'=> { field: 'yavolo_enabled', parent: 'product' }, 
          'delivery_option_id'=> { field: 'delivery_option_id', parent: 'product' },
          # seo
          'seo_title'=> { field: 'title', parent: 'seo_content_attributes' }, 
          'seo_url'=> { field: 'url', parent: 'seo_content_attributes' }, 
          'seo_description'=> { field: 'description', parent: 'seo_content_attributes' }, 
          'seo_keywords'=> { field: 'keywords', parent: 'seo_content_attributes' },
          # ebay
          'ebay_lifetime_sales'=> { field: 'lifetime_sales', parent: 'ebay_detail_attributes' }, 
          'ebay_thirty_day_sales'=> { field: 'thirty_day_sales', parent: 'ebay_detail_attributes' }, 
          'ebay_price'=> { field: 'price', parent: 'ebay_detail_attributes' }, 
          'ebay_thirty_day_revenue'=> { field: 'thirty_day_revenue', parent: 'ebay_detail_attributes' }, 
          'ebay_mpn_number'=> { field: 'mpn_number', parent: 'ebay_detail_attributes' },
          # gog
          'google_title'=> { field: 'title', parent: 'google_shopping_attributes' },
          'google_price'=> { field: 'price', parent: 'google_shopping_attributes' },
          'google_category'=> { field: 'category', parent: 'google_shopping_attributes' },
          'google_campaign_category'=> { field: 'campaign_category', parent: 'google_shopping_attributes' },
          'google_description'=> { field: 'description', parent: 'google_shopping_attributes' },
          'google_exclude_from_google_feed'=> { field:'exclude_from_google_feed', parent:'google_shopping_attributes'},
          'images'=> { parent:'pictures_attributes', separator: '|' }
        }
      end

      def required_csv_fields
        [
        "title", "condition", "width", "depth", "height", "colour", "material", "brand", "keywords", "description", "price", "stock", "sku", "ean", "discount", "yavolo_enabled", "delivery_option_id",
        "seo_title", "seo_url", "seo_description", "seo_keywords",
        "ebay_lifetime_sales", "ebay_thirty_day_sales", "ebay_price", "ebay_thirty_day_revenue", "ebay_mpn_number",
        "google_title", "google_price", "google_category", "google_campaign_category", "google_description", "google_exclude_from_google_feed"
        ]
      end

      def get_params(row)
        product_params = { product: { seo_content_attributes: {}, ebay_detail_attributes: {}, google_shopping_attributes: {} } }
        params_hash = row.to_hash
        params_hash['condition'] = 'brand_new' if params_hash['condition'] == 'new' || params_hash['condition'] == 'New'
        params_hash['seo_title'] = params_hash['title'] if params_hash['seo_title'].blank?
        params_hash['seo_description'] = params_hash['description'] if params_hash['seo_description'].blank?
        params_hash.keys.each do |key|
          field_mapping = field_mappings[key]
          if field_mapping.present?
            if field_mapping[:parent] == 'product'
              product_params[field_mapping[:parent].to_sym][field_mapping[:field].to_sym] = params_hash[key]
            else
              if field_mapping.key?(:separator)
                images_params = get_images_ary(params_hash[key])
                product_params[:product][field_mapping[:parent].to_sym] = images_params if images_params.present?
              else
                product_params[:product][field_mapping[:parent].to_sym][field_mapping[:field].to_sym] = params_hash[key]
              end
            end
          end
        end
        permitted_params(ActionController::Parameters.new(product_params))
      end

      def permitted_params(new_product_params)
        new_product_params.require(:product).permit(:owner_id,:owner_type,
        :title, :condition, :width, :depth, :height, :colour, :material, :brand, :keywords, :description, :price, :stock, :sku, :ean, :discount, :yavolo_enabled, :delivery_option_id,
        seo_content_attributes: [:title, :url, :description, :keywords],
        ebay_detail_attributes: [:lifetime_sales, :thirty_day_sales, :price, :thirty_day_revenue, :mpn_number], google_shopping_attributes: [:title,:price,:category,:campaign_category,:description,:exclude_from_google_feed],
        pictures_attributes: [[:remote_name_url]])
      end

      def have_required_fields?(row)
        params_hash = row.to_hash
        (required_csv_fields-params_hash.keys).blank?
      end

      def get_images_ary(images_column_value)
        return false if images_column_value.blank?
        urls = images_column_value.split('|')
        return false if urls.blank?
        remote_images_ary = []
        urls.map{|url| remote_images_ary << { remote_name_url: url } }
        remote_images_ary
      end

      def get_default_delivery_option_id
        ship_id = Ship.find_or_create_by(name: 'UK Mainland').id

        delivery_option = DeliveryOption.joins(:delivery_option_ships).where(delivery_options: { delivery_optionable_type: csv_import.importer_type, delivery_optionable_id: csv_import.importer_id },delivery_option_ships: {ship_id: ship_id}).last if ship_id.present?

        return delivery_option.id if delivery_option.present?

        delivery_option = importer.delivery_options.create({name: 'Default UK Mainland'})
        DeliveryOptionShip.create(price: 40, processing_time: 'same_day', delivery_time: 'next_day', ship_id: ship_id, delivery_option_id: delivery_option.id)
        delivery_option.id
      end

      def importer
        @importer ||= csv_import.importer
      end

  end
end
