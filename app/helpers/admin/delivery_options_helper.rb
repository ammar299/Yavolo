module Admin::DeliveryOptionsHelper
  def select_processing_time
    DeliveryOptionShip.processing_times.map {|k, v| [k.split('_').map(&:capitalize).join(' '), k]}
  end

  def select_delivery_time
    DeliveryOptionShip.delivery_times.map {|k, v| [k.split('_').map(&:capitalize).join(' '), k]}
  end

  def template_processing_time(time)
    time.split('_').map(&:capitalize).join(' ') if time.present?
  end

  def delivery_ship_price(delivery_option_id, ship_id)
    price = DeliveryOptionShip.find_by(ship_id: ship_id, delivery_option_id: delivery_option_id)&.price
    (delivery_option_id && price).present? ? price : 0.00
  end

  def ship_location(delivery_option)
    delivery_option.ships.pluck(:name)
  end

  def ship_processing_time(delivery_option_id, ship_id)
    DeliveryOptionShip.find_by(ship_id: ship_id, delivery_option_id: delivery_option_id)&.processing_time
  end

  def ship_delivery_time(delivery_option_id, ship_id)
    DeliveryOptionShip.find_by(ship_id: ship_id, delivery_option_id: delivery_option_id)&.delivery_time
  end

  def listed_ship_processing_time(delivery_option_id)
    DeliveryOptionShip.where(delivery_option_id: delivery_option_id).pluck(:processing_time)&.map{ |v| v.split('_').map(&:capitalize).join(' ') if v.present? }
  end

  def listed_ship_delivery_time(delivery_option_id)
    DeliveryOptionShip.where(delivery_option_id: delivery_option_id).pluck(:delivery_time)&.map{ |v| v.split('_').map(&:capitalize).join(' ') if v.present? }
  end

  def checked_delivery_ship?(delivery_option, ship_id)
    delivery_option.ship_ids.include?(ship_id)
  end

  def disable_ships_attribute?(delivery_option_id, ship_id)
    return false if ship_id == 1
    delivery_option = DeliveryOptionShip.find_by(ship_id: ship_id, delivery_option_id: delivery_option_id)
    return delivery_option.present? ? false : (ship_id != 1)
  end

  def parse_delivery_option_name(delivery_option)
    return unless delivery_option.present?
    delivery_option.split('_').map(&:capitalize).join(' ')
  end
end
