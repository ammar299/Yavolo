module Products
  class Exporter < ApplicationService
    require 'csv'
    attr_reader :status, :errors, :params, :csv_file

    def initialize(params)
        @params = params
        @status = true
        @errors = []
        @csv_file = nil
    end

    def call
      begin
        generate_csv
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private
      def generate_csv
        headers = get_csv_headers 
        @csv_file = CSV.generate(headers: true) do |csv|
          csv << headers
          @products = owner
          @products.each do |product|
            csv << get_columns_values(product)   
          end
        end
      end

      def get_csv_headers
        [
          "title", "condition", "width", "depth", "height", "colour", "material", "brand", "keywords", "description", "price", "stock", "sku", "ean", "discount", "yavolo_enabled", "delivery_option_id",
          "seo_title", "seo_url", "seo_description", "seo_keywords",
          "ebay_lifetime_sales", "ebay_thirty_day_sales", "ebay_price", "ebay_thirty_day_revenue", "ebay_mpn_number",
          "google_title", "google_price", "google_category", "google_campaign_category", "google_description", "google_exclude_from_google_feed","images","featured_image_index","seller"
        ]
      end

      def get_columns_values(product)
        values = []
        get_csv_headers.slice(0, get_csv_headers.index('seo_title')).each do |col|
          if col == 'ean'
            values << "ean_#{product.send(col).to_s}"
          elsif col == 'delivery_option_id'
            values << get_delivery_option_id(product.delivery_option_id)
          else
            values << product.send(col).to_s
          end
        end
        so = product.seo_content
        values << [so.title,so.url,so.description,so.keywords] if so.present?
        ebay = product.ebay_detail
        values << [ebay.lifetime_sales,ebay.thirty_day_sales, ebay.price, ebay.thirty_day_revenue, ebay.mpn_number] if ebay.present?
        ginfo = product.google_shopping
        values << [ginfo.title, ginfo.price, ginfo.category, ginfo.campaign_category, ginfo.description,ginfo.exclude_from_google_feed ] if ginfo.present?
        values << product.pictures.order(id: :asc).map{|p| p.name.url}.join("|")
        values << featured_image_index(product)
        values << seller_name(product)
        values.flatten
      end

      def owner
        @owner ||= params[:owner]
      end

      def seller_name(product)
        if product.owner_type == "Seller"
          "#{product.owner.first_name} #{product.owner.last_name}"
        else
          "Admin"
        end
      end

    def featured_image_index(product)
      index = nil
      featured_image = product.get_featured_image
      if featured_image.present?
        index = product.pictures.order(id: :asc).index { |p| p.id == featured_image.id }
      end
      index
    end

      def get_delivery_option_id(delivery_option_id)
        DeliveryOption.find(delivery_option_id).handle
      end
  end
end
