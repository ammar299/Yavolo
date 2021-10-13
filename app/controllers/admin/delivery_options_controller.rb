class Admin::DeliveryOptionsController < Admin::BaseController
  before_action :set_delivery_option, only: %i[edit update destroy]

  def index
    @delivery_options = DeliveryOption.all
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
      @delivery_options = DeliveryOption.all
    else
      @delivery_option.errors[:base] << 'Template already exists!'
      render :new
    end
  end

  def update
    @delivery_opts = true
    delivery_option_filtering

    if @delivery_opts == true
      @delivery_option.update(delivery_option_params)
      create_delivery_option_ships(@delivery_option)
      @delivery_options = DeliveryOption.all
    else
      @delivery_option.errors[:base] << 'Template already exists!'
      render :edit
    end
  end

  def destroy
    @delivery_option.destroy
    redirect_to admin_delivery_options_path
  end

  def delete_delivery_options
    DeliveryOption.where(id: params['ids'].split(',')).destroy_all
    @delivery_options = DeliveryOption.all
  end

  private

  def delivery_option_params
    params.require(:delivery_option).permit(:name, :processing_time, :delivery_time)
  end

  def set_delivery_option
    @delivery_option = DeliveryOption.find(params[:id])
  end

  def delivery_option_filtering
    delivery_options = DeliveryOption.where(delivery_option_params)
    if delivery_options.exists?
      check_delivery_option_availbility(delivery_options)
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
      bool = delivery_ships.as_json.transform_values(&:to_s) == filter_ship_ids
      return @delivery_opts = false if bool
    end
  end
end
