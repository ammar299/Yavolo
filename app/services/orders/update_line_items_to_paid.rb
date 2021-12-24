module Orders
  # This service is responsible to transfer amount to sellers against their orders
  class UpdateLineItemsToPaid < ApplicationService
    attr_reader :status, :errors, :params

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
    end

    def call
      begin
        update_line_item
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    def update_line_item
      line_items_array.each do |line_item|
        item = LineItem.find(line_item[:id]) rescue nil
        if item.present?
          item.update(price: line_item[:price], transfer_id: transfer_id, transfer_status: :paid)
        end
      end
    end

    private

    def line_items_array
      params[:products_array] || []
    end

    def seller_id
      params[:seller_id] || nil
    end

    def transfer_id
      params[:transfer_id] || nil
    end
  end
end