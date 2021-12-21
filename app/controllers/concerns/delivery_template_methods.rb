module DeliveryTemplateMethods
  extend ActiveSupport::Concern

  def filter_ship_ids
    unselected_ships = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_price']]
    unselected_ship_processing_times = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_processing_time']]
    unselected_ship_delivery_times = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_delivery_time']]
    @selected_ships = {}
    @selected_ship_processing_times = {}
    @selected_ship_delivery_times = {}
    @selected_ships = unselected_ships.slice(*params['delivery_option']['ship_ids'].reject(&:blank?))
    @selected_ship_processing_times = unselected_ship_processing_times.slice(*params['delivery_option']['ship_ids'].reject(&:blank?))
    @selected_ship_delivery_times = unselected_ship_delivery_times.slice(*params['delivery_option']['ship_ids'].reject(&:blank?))
  end

  def delivery_option_filtering(delivery_option=nil)
    delivery_options = DeliveryOption.where(name: delivery_option_params[:name])
    delivery_options = delivery_options.where.not(id: delivery_option.id) if !delivery_option.nil?
    if delivery_options.present?
      check_delivery_option_availbility(delivery_options)
    else
      @delivery_opts = true
    end
  end

  def create_delivery_option_ships(delivery_option)
    delivery_option.ships.destroy_all if delivery_option.ships.exists?
    filter_ship_ids
    @selected_ships.each do |ship_id, price|
      DeliveryOptionShip.create(price: price.split('£').join('').split(',').join(''), processing_time: @selected_ship_processing_times[ship_id], delivery_time: @selected_ship_delivery_times[ship_id], ship_id: ship_id, delivery_option_id: delivery_option.id)
    end
  end

  def comparing_delivery_template_ships(delivery_option)
    delivery_option.delivery_option_ships.each_with_index do |delivery_ship, index|
      @delivery_ship_array << delivery_ship.ship_id << delivery_ship.price.to_f.to_s << delivery_ship.processing_time << delivery_ship.delivery_time
    end
    @selected_ships.each_with_index do |delivery_ship, index|
      price = @selected_ships.values[index] == ''? '0.0' : @selected_ships.values.join('').split('£')[index].split(',').join('')
      @filter_ship_ids_array << @selected_ships.keys[index].to_i << price.split(',').map{|e| e.include?('.') ? e.to_f : e}.join(',') << @selected_ship_processing_times.values[index] << @selected_ship_delivery_times.values[index]
    end
  end

  def persisted_delivery_ships
    @ship_ids = params[:delivery_option][:ship_ids].reject(&:empty?)
    @ship_prices = params['ship_price']
    @ship_processing_times = params['ship_processing_time']
    @ship_delivery_times = params['ship_delivery_time']
  end
end
