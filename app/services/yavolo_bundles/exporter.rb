module YavoloBundles
  class Exporter < ApplicationService
    require 'csv'
    attr_reader :status, :yavolos_ids, :csv_file

    def initialize(yavolos_ids)
      @yavolos_ids = yavolos_ids
      @status = true
      @csv_file = nil
    end

    def call
      begin
        @csv_file = export_yavolos
      rescue StandardError => e
        @status = false
        Rails.logger.log "Error while exporting csv. #{e.message}"
      end
      self
    end

    private

    def export_yavolos
      yavolos = yavolos_ids&.split(",")
      CSV.generate(headers: true) do |csv|
        max_bundled_products ||= get_max_product_number(yavolos)
        csv_headers = []
        csv_headers << csv_headers_yavolo
        csv_headers << csv_headers_yavolo_products(max_bundled_products)
        csv << csv_headers.flatten
        yavolos.each do |yavolo|
          yavolo = YavoloBundle.where(id: yavolo.to_i).last
          if yavolo.present?
            csv << create_row_in_csv(max_bundled_products, yavolo)
          end
        end
      end
    end

    def create_row_in_csv(max, yavolo)
      csv_row = []
      csv_row << [yavolo.title, get_category(yavolo.category_id), yavolo.description, yavolo.max_stock_limit, yavolo.stock_limit, yavolo.price,
                  get_main_image(yavolo), get_photos(yavolo),
                  yavolo.seo_content&.title, yavolo.seo_content&.url, yavolo.seo_content&.keywords, yavolo.seo_content&.description,
                  yavolo.google_shopping&.title, yavolo.google_shopping&.price, yavolo.google_shopping&.category, yavolo.google_shopping&.campaign_category, yavolo.google_shopping&.description, yavolo.google_shopping&.exclude_from_google_feed
      ]
      csv_row << get_product_values(max, yavolo)
      csv_row.flatten
    end

    def get_main_image(yavolo)
      main_image = yavolo.main_image
      main_image.name.url if main_image.present?
    end

    def get_photos(yavolo)
      yavolo.pictures.map { |p| p.name.url }.join("|")
    end

    def get_product_values(max, yavolo)
      csv_row = []
      (0...max).each do |i|
        next unless yavolo.products[i].present?
        [:ean, :title, :price, :width, :depth, :height, :colour, :material, :keywords, :description].each do |sym|
          csv_row << yavolo.products[i][sym]
        end
      end
      return csv_row
    end

    def get_max_product_number(yavolos)
      max_bundled_products = []
      yavolos&.each do |yavolo|
        max_bundled_products << YavoloBundle.where(id: yavolo.to_i)&.last&.products&.count
      end
      return max_bundled_products.max
    end

    def csv_headers_yavolo
      %w(yavolo_title yavolo_category yavolo_description yavolo_stock_display_limit yavolo_stock_limit adjust_to_price  yavolo_main_image yavolo_photos
          meta_title meta_url meta_keywords meta_description
          google_shopping_title google_shopping_price google_shopping_category google_shopping_campaign_category google_shopping_description google_exclude_from_google_feed
      )
    end

    def csv_headers_yavolo_products(max)
      csv_row = []
      (1..max).each do |i|
        [:ean, :title, :adjusted_price, :width, :depth, :height, :colour, :material, :keywords, :description].each do |sym|
          csv_row << "product_#{i}_#{sym}"
        end
      end
      return csv_row
    end

    def get_category(id)
      Category.find(id)&.category_name rescue ""
    end
  end
end
