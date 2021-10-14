module Admin::DeliveryOptionsHelper
  def select_processing_time
    DeliveryOption.processing_times.map {|k, v| [k.split('_').map(&:capitalize).join(' '), k]}
  end

  def select_delivery_time
    DeliveryOption.delivery_times.map {|k, v| [k.split('_').map(&:capitalize).join(' '), k]}
  end

  def template_processing_time(time)
    time.split('_').map(&:capitalize).join(' ')
  end

  def delivery_ship_price(delivery_option_id, ship_id)
    price = DeliveryOptionShip.find_by(ship_id: ship_id, delivery_option_id: delivery_option_id)&.price
    (delivery_option_id && price).present? ? price : 0.00
  end

  def checked_delivery_ship?(delivery_option, ship_id)
    delivery_option.ship_ids.include?(ship_id)
  end
end
