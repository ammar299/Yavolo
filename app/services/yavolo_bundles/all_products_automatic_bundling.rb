module YavoloBundles
  class AllProductsAutomaticBundling < ApplicationService

    def initialize
    end

    def call
      # Flowchart link: https://docs.google.com/spreadsheets/d/16nxXR3hxAn8dE7auPMNkbvLtUN2ofShyUQfPDI0Wmfc/edit#gid=0
      product_assignment_settings = ProductAssignmentSetting.first
      ProductAssignmentSetting.create_default if product_assignment_settings.nil?

      # Assign new priorites on each month
      ProductAssignment.delete_all

      Product.includes(:ebay_detail).active.yavolo_enabled.find_each(batch_size: 100) do |product|
        if has_item_sold_on_yavolo(product)
          yavolo_criteria = product_match_criteria_on_yavolo(product)
          if yavolo_criteria[:criteria_fulfilled]
            assign_high_priority_to_product(product, yavolo_criteria)
          else
            assign_priority_to_seller_best_product(product)
          end
        elsif has_item_sold_on_ebay(product)
          ebay_criteria = product_match_criteria_on_ebay(product)
          if ebay_criteria[:criteria_fulfilled]
            assign_high_priority_to_product(product, ebay_criteria)
          else
            assign_priority_to_seller_best_product(product)
          end
        else
          assign_low_priority_to_product(product, default_criteria_values)
        end
      end
    end


    private

    def default_criteria_values
      {
          total_revenue: 0.00,
          total_sales: 0
      }
    end

    def assign_high_priority_to_product(product, criteria)
      if product.category.bundle_label == "ya"
        create_product_assignment(product, criteria, ProductAssignment.priorities[:worthy_ya])
      elsif product.category.bundle_label == "volo"
        create_product_assignment(product, criteria, ProductAssignment.priorities[:worthy_volo])
      elsif product.category.bundle_label == "yavolo"
        create_product_assignment(product, criteria, ProductAssignment.priorities[:worthy_ya_volo])
      end
    end

    def create_product_assignment(product, criteria, priority)
      return if ProductAssignment.exists?(product: product, priority: ProductAssignment.worthy_values) # High Priority is assigned to this product already based on best product
      existing_product = ProductAssignment.find_by(product: product)
      existing_product.destroy if existing_product.present?
      ProductAssignment.create(product: product, total_sales: criteria[:total_sales], total_revenue: criteria[:total_revenue], priority: priority)
    end

    def assign_low_priority_to_product(product, criteria)
      if product.category.bundle_label == "ya"
        create_product_assignment(product, criteria, ProductAssignment.priorities[:unworthy_ya])
      elsif product.category.bundle_label == "volo"
        create_product_assignment(product, criteria, ProductAssignment.priorities[:unworthy_volo])
      elsif product.category.bundle_label == "yavolo"
        create_product_assignment(product, criteria, ProductAssignment.priorities[:unworthy_ya_volo])
      end
    end

    def assign_priority_to_seller_best_product(product)
      return if has_seller_got_high_priority_product(product)
      best_product_hash = best_product_based_on_sale_history(product)
      if best_product_hash.present?
        best_product = Product.find_by(id: best_product_hash[:product_id])
        return unless best_product.present?
        criteria = {
            total_sales: best_product_hash[:total_sales],
            total_revenue: best_product_hash[:total_revenue]
        }
        assign_high_priority_to_product(best_product, criteria)
      end
    end

    def has_item_sold_on_yavolo(product)
      LineItem.includes(:order).where(product: product, order: {order_type: Order.order_types["paid_order"]}).count.positive?
    end

    def has_item_sold_on_ebay(product)
      product.ebay_detail.present? && (product.ebay_detail.thirty_day_sales.present? || product.ebay_detail.thirty_day_revenue.present?)
    end

    def product_match_criteria_on_yavolo(product)
      product_assignment_settings = ProductAssignmentSetting.first
      unless product_assignment_settings.present?
        return {criteria_fulfilled: false}
      end
      @product_line_items = LineItem.includes(:order).where(product: product, order: {order_type: Order.order_types["paid_order"]})
                                .where("line_items.created_at > current_date - interval '#{product_assignment_settings.duration} day'")
      total_revenue = @product_line_items.inject(0.0) { |sum, li| sum += (li.price * li.quantity) }
      total_sales = @product_line_items.sum(:quantity)
      {
          total_revenue: total_revenue,
          total_sales: total_sales,
          criteria_fulfilled: total_revenue >= product_assignment_settings.price || total_sales >= product_assignment_settings.items
      }
    end

    def product_match_criteria_on_ebay(product)
      product_assignment_settings = ProductAssignmentSetting.first
      unless product_assignment_settings.present? && product.ebay_detail.present?
        return {criteria_fulfilled: false}
      end
      total_revenue = product.ebay_detail.thirty_day_revenue || 0.00
      total_sales = product.ebay_detail.thirty_day_sales || 0
      {
          total_revenue: total_revenue,
          total_sales: total_sales,
          criteria_fulfilled: total_revenue >= product_assignment_settings.price || total_sales >= product_assignment_settings.items
      }
    end

    def has_seller_got_high_priority_product(product)
      if product.owner&.class&.name == Seller.to_s
        Product.active_products(product.owner).joins(:product_assignments).where(product_assignments: {priority: ProductAssignment.worthy_values}).count > 0
      else
        true
      end
    end

    def best_product_based_on_sale_history(product)
      return unless product.owner&.class&.name == Seller.to_s
      product_ids = Product.active_products(product.owner).pluck(:id)

      # check for best product on yavolo first
      yavolo_line_items = LineItem.group(:product_id).joins(:order).where(product_id: product_ids, order: {order_type: Order.order_types["paid_order"]}).sum('line_items.price * line_items.quantity')
      if yavolo_line_items.present?
        best_yavolo_product_id_and_revenue = yavolo_line_items.max_by(&:last) # This line will return an array like [2, 0.1802e4]
        best_yavolo_product_id = best_yavolo_product_id_and_revenue.first
        best_yavolo_product_revenue = best_yavolo_product_id_and_revenue.last.to_f
        best_yavolo_product_sales = LineItem.joins(:order).where(product_id: best_yavolo_product_id, order: {order_type: Order.order_types["paid_order"]}).sum(:quantity)
        return {
            product_id: best_yavolo_product_id,
            total_revenue: best_yavolo_product_revenue,
            total_sales: best_yavolo_product_sales
        }
      end

      # If best product not found on yavolo check for best product on ebay
      ebay_best_product = EbayDetail.where(product_id: product_ids).where.not(thirty_day_revenue: nil).order('thirty_day_revenue desc').first
      if ebay_best_product.present?
        return {
            product_id: ebay_best_product.product_id,
            total_revenue: ebay_best_product.thirty_day_revenue.to_f,
            total_sales: ebay_best_product.thirty_day_sales
        }
      end
    end
  end
end