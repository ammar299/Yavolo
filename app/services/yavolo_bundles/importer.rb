module YavoloBundles
  class Importer < ApplicationService
    require 'csv'
    attr_reader :status, :errors, :params, :title_list

    def initialize(params)
      @params = params
      @status = true
      @errors = []
      @title_list = []
      @max_products_count = 0
    end

    def call
      begin
        catch :break do
          import_yavolos_from_csv
        end
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def import_yavolos_from_csv
      file_path = "#{Rails.root}/public/#{csv_import.file.url}"
      csv_file_conent = File.read(file_path)
      csv = CSV.parse(csv_file_conent, :headers => true)
      @max_products_count = get_max_header_product_number(csv.headers)
      csv_import.update({status: :importing})
      csv.each do |row|
        @current_yavolo = row["yavolo_title"]
        @current_yavolo_errors = []
        @current_yavolos_products = []
        yavolo = YavoloBundle.new(title: @current_yavolo, description: row["yavolo_description"], max_stock_limit: row["yavolo_stock_display_limit"], price: row["adjust_to_price"], status: :live)
        assign_category(yavolo, row["yavolo_category"])
        assign_yavolo_bundle_products(yavolo, row)
        calculate_quantity_of_products(yavolo)
        calculate_stock_limit(yavolo)
        calculate_regular_and_yavolo_total(yavolo)
        associate_main_image(yavolo, row)
        associate_pictures(yavolo, row)
        associate_seo_content(yavolo, row)
        associate_google_shopping(yavolo, row)
        update_associate_products(row)
        if yavolo.valid? && @current_yavolo_errors.empty?
          yavolo.save
        else
          @current_yavolo_errors << yavolo.errors.full_messages
          @errors << {
              yavolo_title: @current_yavolo,
              errors: @current_yavolo_errors.flatten.join(', ')
          }
          @title_list << @current_yavolo
        end

      end
      @errors.present? ? csv_import.update(status: :failed, import_errors: @errors, title_list: @title_list) : csv_import.update({status: :imported})
      @status = @errors.empty?
      self
    end

    def update_associate_products(row)
      max_value = get_max_product_number_in_row(row)
      (1..max_value).each do |i|
        column_value = get_row_column_by_index_and_name(row, i, "ean")
        next unless column_value.present?
        product = Product.find_by(ean: column_value)
        next unless product.present?
        %w(title keywords description).each do |key|
          field_value = get_row_column_by_index_and_name(row, i, key)
          product[key.to_sym] = field_value if field_value.present?
        end
        unless product.save
          @current_yavolo_errors << "Product #{product.title} :  #{product.errors&.full_messages&.join(",")}"
        end
      end
    end

    def associate_google_shopping(yavolo, row)
      exclude_from_shopping = row["google_exclude_from_google_feed"].to_s.downcase == 'true'
      yavolo.build_google_shopping(title: row["google_shopping_title"], price: row["google_shopping_price"], category: row["google_shopping_category"],
                                   campaign_category: row["google_shopping_campaign_category"], description: row["google_shopping_description"], exclude_from_google_feed: exclude_from_shopping)
    end

    def associate_seo_content(yavolo, row)
      yavolo.build_seo_content(title: row["meta_title"], url: row["meta_url"], description: row["meta_description"], keywords: row["meta_keywords"])
    end

    def associate_pictures(yavolo, row)
      featured_images = []
      # Get featured images of associated products
      @current_yavolos_products.each do |product|
        featured_img = product.get_featured_image
        next unless featured_img.present?
        url = Rails.env.development? ? "#{ENV['HOST_URL']}#{featured_img.name.url}" : featured_img.name.url
        featured_images << {remote_name_url: url}
      end
      #Add extra images also if present in csv
      get_images_ary(row["yavolo_photos"], featured_images)
      yavolo.pictures_attributes= featured_images
    end

    def get_images_ary(images_column_value, featured_images)
      return if images_column_value.blank?
      urls = images_column_value.split('|')
      return if urls.blank?
      urls.map { |url| featured_images << {remote_name_url: url} }
      featured_images
    end

    def associate_main_image(yavolo, row)
      main_image = row["yavolo_main_image"]
      return unless main_image.present?
      # TODO: This will be tested after save
      yavolo.main_image_attributes = {remote_name_url: main_image}
    end

    def calculate_regular_and_yavolo_total(yavolo)
      yavolo_total = 0.00
      regular_total = 0.00
      @current_yavolos_products.each do |product|
        yavolo_total += (product.get_discount_price || product.price)
        regular_total += product.price
      end
      yavolo.regular_total = regular_total
      yavolo.yavolo_total = yavolo_total
    end

    def calculate_quantity_of_products(yavolo)
      yavolo.quantity = yavolo.yavolo_bundle_products.size
    end

    def assign_yavolo_bundle_products(yavolo, row)
      max_value = get_max_product_number_in_row(row)
      (1..max_value).each do |i|
        ybp = build_yavolo_bundle_product(row, i)
        yavolo.yavolo_bundle_products << ybp if ybp.present?
      end
    end

    def build_yavolo_bundle_product(row, i)
      column_value = get_row_column_by_index_and_name(row, i, "ean")
      return unless column_value.present?
      product = Product.find_by(ean: column_value)
      unless product.present?
        @current_yavolo_errors << "Product with ean #{column_value} does not exist. This product will not be added to bundle"
        return
      end
      @current_yavolos_products << product
      product_price = get_row_column_by_index_and_name(row, i, "adjusted_price")
      product_price = strip_currency_from_price(product_price) if product_price.present?
      YavoloBundleProduct.new(product: product, price: product_price)
    end

    def get_row_column_by_index_and_name(row, i, name)
      row["product_#{i}_#{name}"]
    end

    def strip_currency_from_price(amount)
      amount.split('£').join('').delete(',') if amount.present?
    end

    def get_product_values(max, yavolo)
      csv_row = []
      (0...max).each do |i|
        next unless yavolo.products[i].present?
        [:ean, :title, :width, :depth, :height, :colour, :material, :keywords, :description].each do |sym|
          csv_row << yavolo.products[i][sym]
        end
      end
      return csv_row
    end

    def get_max_product_number_in_row(row)
      # We will iterate over columns of this row and see where the product ean is blank. That mean we have this many products in this row
      products_in_row = 0
      (1..@max_products_count).each do |i|
        next unless row["product_#{i}_ean"].present?
        products_in_row += 1
      end
      products_in_row
    end

    # This functions returns max value of bundle product header in csv
    def get_max_header_product_number(csv_headers)
      ean_headers = csv_headers.select { |h| h.match(/product_\d{1}_ean/) }
      ean_headers = ean_headers.map { |h| h.scan(/\d/).join('').to_i }
      ean_headers.max
    end

    def assign_category(yavolo, category_name)
      return unless category_name.present?
      category = Category.find_by(category_name: category_name)
      yavolo.category_id = category.id if category.present?
    end

    def calculate_stock_limit(yavolo)
      leastStock = @current_yavolos_products.pluck(:stock).min
      yavolo.stock_limit = leastStock if leastStock.present?
    end

    def csv_import
      @csv_import ||= params[:csv_import]
    end
  end
end
