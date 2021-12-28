module OrdersHelper

  def get_vat_numbers(order)
    vat_number_collection = []
    order.line_items.seller_own_order_line_items(current_seller).each do |line_item|
      vat_number = line_item&.product&.owner&.company_detail&.vat_number rescue nil
      vat_number_collection.push(vat_number)
    end
    vat_number_collection.compact.uniq.join(", ")
  end

  def get_full_name(object)
    "#{object.first_name.present? ? object.first_name : ''}" "#{object.last_name.present? ? object.last_name : ''}"
  end

end