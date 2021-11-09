class Admin::DeliveryOptionsController < Admin::BaseController
  before_action :set_delivery_option, only: %i[edit update confirm_delete destroy delete_delivery_option]
  before_action :set_seller_id, only: %i[edit new]

  def index
    @delivery_options = DeliveryOption.admin_delivery_option("Admin")
    @carriers = Carrier.all
  end

  def new
    @delivery_option = DeliveryOption.new
  end

  def create
    @delivery_opts = true
    delivery_option_filtering

    @delivery_option = DeliveryOption.new(delivery_option_params)
    if @delivery_opts == true
      @delivery_option.save
      create_delivery_option_ships(@delivery_option)
      manage_delivery_options_list(@delivery_option)
    else
      persisted_delivery_ships
      flash.now[:notice] = 'Template already exists!'
      render :new
    end
  end

  def update
    @existing_obj = true
    @delivery_opts = true
    verify_delivery_option(@delivery_option)
    delivery_option_filtering(@delivery_option) if @existing_obj == false
    if @existing_obj == true || @delivery_opts == true
      @delivery_option.update(delivery_option_params)
      create_delivery_option_ships(@delivery_option)
      manage_delivery_options_list(@delivery_option)
    else
      @delivery_option_name = params[:delivery_option][:name]
      persisted_delivery_ships
      flash.now[:notice] = 'Template already exists!'
      render :edit
    end
  end

  def destroy
    @delivery_option.destroy
    redirect_to admin_delivery_options_path
  end

  def delete_delivery_options
    DeliveryOption.where(id: params['ids'].split(',')).destroy_all
    @delivery_options = DeliveryOption.admin_delivery_option("Admin")
  end

  def delete_delivery_option
    @delivery_option.destroy
    @delivery_options = DeliveryOption.where(delivery_optionable_type: "Seller", delivery_optionable_id: @delivery_option.delivery_optionable_id)
  end

  def search_seller_delivery_options
    if params[:search].present?
      seller_id = Seller.find(params[:seller_id])
      @delivery_options = DeliveryOption.where(delivery_optionable_type: "Seller", delivery_optionable_id: seller_id).global_search(params[:search])
    else 
      seller_id = Seller.find(params[:seller_id])
      @delivery_options = DeliveryOption.where(delivery_optionable_type: "Seller", delivery_optionable_id: seller_id)
    end
  end

  private

  def delivery_option_params
    params.require(:delivery_option).permit(:name, :ship_ids, :delivery_optionable_type, :delivery_optionable_id)
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
    if delivery_options.exists?
      check_delivery_option_availbility(delivery_options)
    else
      @delivery_opts = true
    end
  end

  def filter_ship_ids
    unselected_ships = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_price']]
    unselected_ship_processing_times = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_processing_time']]
    unselected_ship_delivery_times = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_delivery_time']]
    @selected_ship = {}
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
      @delivery_opts = false if bool
    end
  end

  def set_seller_id
    @seller_id = params[:seller_id] if params[:seller_id].present?
  end

  def manage_delivery_options_list(delivery_option)
    if delivery_option.delivery_optionable_type == 'Seller'
      @delivery_options = DeliveryOption.where(delivery_optionable_type: 'Seller', delivery_optionable_id: params[:delivery_option][:delivery_optionable_id])
      @seller_id = params[:seller_id] || params[:delivery_option][:delivery_optionable_id]
    else
      @delivery_options = DeliveryOption.admin_delivery_option('Admin')
    end
  end

  def persisted_delivery_ships
    @ship_ids = params[:delivery_option][:ship_ids].reject(&:empty?)
    @ship_prices = params['ship_price']
    @ship_processing_times = params['ship_processing_time']
    @ship_delivery_times = params['ship_delivery_time']
  end
end
