module Orders
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
          @orders = owner
          @orders.each do |order|
            csv << get_columns_values(order)   
          end
        end
      end

      def get_csv_headers
        [
          "order_number", "customer", "seller", "total", "item(s)", "yavolo", "carrier", "tracking_no", "status"
        ]
      end

      def get_columns_values(order)
        values = []
        values << order.id
        values << order_customer(order)
        values << order_seller_name(order)
        values << order.total
        values << order.line_items.count
        values << "Image"
        values << "Royal Mail"
        values << "#75757757"
        values << order.order_type
        values.flatten
      end

      def get_price_in_pounds(amount)
        amount.present? ? number_to_currency(amount, unit: "£", precision: 2) : 0
      end

      def owner
        @owner ||= params[:owner]
      end

      def order_customer(order)
        
        order&.order_detail&.name&.present? ? order.order_detail.name : 'Yavolo customer'
      end

      def order_seller_name(order)
        order&.line_items&.first&.product&.owner&.full_name&.present? ? order.line_items.first.product.owner.full_name : 'john doe'
      end

  end
end
