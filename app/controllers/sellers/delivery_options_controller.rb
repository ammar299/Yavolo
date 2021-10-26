class Sellers::DeliveryOptionsController < Sellers::BaseController
  before_action :set_delivery_option, only: %i[edit update confirm_delete destroy]

  def index
    if params[:search].present?
      @delivery_options = current_seller.delivery_options.global_search(params[:search])
    else 
      @delivery_options = current_seller.delivery_options
    end
  end

  def new
    @delivery_option = current_seller.delivery_options.new
  end

  def create
    @delivery_opts = true
    @errors = 'Template already exists!'
    delivery_option_filtering
    @delivery_option = DeliveryOption.new(delivery_option_params)
    if @delivery_opts == true
      @delivery_option.save
      create_delivery_option_ships(@delivery_option)
      @delivery_options = current_seller.delivery_options
    else
      @delivery_option.errors[:base] << @errors
      render :new
    end
  end

  def update
    @existing_obj = true
    @delivery_opts = true
    @errors = 'Template already exists'
    verify_delivery_option(@delivery_option)
    delivery_option_filtering(@delivery_option) if @existing_obj == false
    params[:delivery_option][:ship_ids] = params[:delivery_option][:ship_ids].reject { |c| c.empty? }
    if @existing_obj == true || @delivery_opts == true
      @delivery_option.update(delivery_option_params)
      create_delivery_option_ships(@delivery_option)
      @delivery_options = current_seller.delivery_options
    else
      @delivery_option.errors[:base] << @errors
      render :edit
    end
  end

  def destroy
    @delivery_option.destroy
    @delivery_options = current_seller.delivery_options
  end

  def delete_delivery_options
    DeliveryOption.where(id: params['ids'].split(',')).destroy_all
    @delivery_options = current_seller.delivery_options
  end

  private

  def delivery_option_params
    params.require(:delivery_option).permit(:name, :processing_time, :delivery_time, :ship_ids, :delivery_optionable_type, :delivery_optionable_id )
  end

  def set_delivery_option
    @delivery_option = DeliveryOption.find(params[:id])
  end

  def verify_delivery_option(delivery_option)
    if delivery_option.id == DeliveryOption.find_by(delivery_option_params)&.id
      delivery_ships = DeliveryOptionShip.where(delivery_option_id: delivery_option.id).map{ |c| [c.ship_id, c.price.to_f] }.to_h
      result = delivery_ships == filter_ship_ids.transform_keys(&:to_i).transform_values(&:to_f)
      @existing_obj = result
    else
      @existing_obj = false
    end
  end

  def delivery_option_filtering(delivery_option=nil)
    delivery_options = DeliveryOption.where(name: delivery_option_params[:name], processing_time: delivery_option_params[:processing_time], delivery_time: delivery_option_params[:delivery_time])
    delivery_options = delivery_options.where.not(id: delivery_option.id) if !delivery_option.nil?
    if delivery_options.present?
      check_delivery_option_availbility(delivery_options)
    else
      @delivery_opts = true
    end
  end

  def filter_ship_ids
    unselected_ships = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_price']]
    @selected_ships = {}
    @selected_ships = unselected_ships.slice(*params['delivery_option']['ship_ids'].reject(&:blank?))
  end

  def create_delivery_option_ships(delivery_option)
    delivery_option.ships.destroy_all if delivery_option.ships.exists?
    filter_ship_ids
    @selected_ships.each do |ship_id, price|
      DeliveryOptionShip.create(price: price, ship_id: ship_id, delivery_option_id: delivery_option.id)
    end
  end

  def check_delivery_option_availbility(delivery_options)
    delivery_options.each do |delivery_option|
      delivery_ships = DeliveryOptionShip.where(delivery_option_id: delivery_option.id).map{ |c| [c.ship_id, c.price.to_f] }.to_h
      result = delivery_ships == filter_ship_ids.transform_keys(&:to_i).transform_values(&:to_f)
      @errors = 'Template exists in Global Templates' if result && (delivery_option.delivery_optionable_type == 'Admin')
      @delivery_opts = false if result
    end
  end
end
