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
      flash.now[:notice] = @errors
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
      flash.now[:notice] = @errors
      render :edit
    end
  end

  def destroy
    @delivery_option.destroy
    @delivery_options = current_seller.delivery_options
    redirect_to sellers_delivery_options_path
  end

  def delete_delivery_options
    DeliveryOption.where(id: params['ids'].split(',')).destroy_all
    @delivery_options = current_seller.delivery_options
  end

  private

  def delivery_option_params
    params.require(:delivery_option).permit(:name, :ship_ids, :delivery_optionable_type, :delivery_optionable_id )
  end

  def set_delivery_option
    @delivery_option = DeliveryOption.find(params[:id])
  end

  def verify_delivery_option(delivery_option)
    if delivery_option.id == DeliveryOption.find_by(delivery_option_params)&.id
      filter_ship_ids
      result = 0
      delivery_option.delivery_option_ships.each_with_index do |delivery_ship, index|
        delivery_ship_array = []
        filter_ship_ids_array = []
        delivery_ship_array << delivery_ship.price.to_f.to_s << delivery_ship.processing_time << delivery_ship.delivery_time
        filter_ship_ids_array << @selected_ships.values.join('').split('£').reject(&:blank?)[index] << @selected_ship_processing_times.values[index] << @selected_ship_delivery_times.values[index]
        result += 1 if (delivery_ship_array == filter_ship_ids_array)
      end
      @existing_obj = result == delivery_option.delivery_option_ships.count
    else
      @existing_obj = false
    end
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

  def create_delivery_option_ships(delivery_option)
    delivery_option.ships.destroy_all if delivery_option.ships.exists?
    filter_ship_ids
    @selected_ships.each do |ship_id, price|
      DeliveryOptionShip.create(price: price.split('£').join(''), processing_time: @selected_ship_processing_times[ship_id], delivery_time: @selected_ship_delivery_times[ship_id], ship_id: ship_id, delivery_option_id: delivery_option.id)
    end
  end

  def check_delivery_option_availbility(delivery_options)
    filter_ship_ids
    delivery_options.each do |delivery_option|
      result = 0
      delivery_option.delivery_option_ships.each_with_index do |delivery_ship, index|
        delivery_ship_array = []
        filter_ship_ids_array = []
        delivery_ship_array << delivery_ship.price.to_f.to_s << delivery_ship.processing_time << delivery_ship.delivery_time
        filter_ship_ids_array << @selected_ships.values.join('').split('£').reject(&:blank?)[index] << @selected_ship_processing_times.values[index] << @selected_ship_delivery_times.values[index]
        result += 1 if (delivery_ship_array == filter_ship_ids_array)
      end
      bool = (result == delivery_option.delivery_option_ships.count)
      @errors = 'Template exists in Global Templates' if bool && (delivery_option.delivery_optionable_type == 'Admin')
      @delivery_opts = false if bool
    end
  end
end
