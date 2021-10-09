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
    @delivery_option = DeliveryOption.new(delivery_option_params)
    if @delivery_option.save
      delivery_option_ships(@delivery_option)
      redirect_to admin_delivery_options_path
    else
      render :new
    end
  end

  def update
    if @delivery_option.update(delivery_option_params)
      delivery_option_ships(@delivery_option)
      redirect_to admin_delivery_options_path
    else
      render :edit
    end
  end

  def delivery_option_ships(delivery_option)
    delivery_option.ships.destroy_all if delivery_option.ships.exists?
    unselected_ships = Hash[Ship.pluck(:id).map(&:to_s).zip params['ship_price']]
    selected_ships = {}
    selected_ships = unselected_ships.slice(*params['delivery_option']['ship_ids'].reject(&:blank?))
    selected_ships.each do |ship_id, price|
      DeliveryOptionShip.create(price: price, ship_id: ship_id, delivery_option_id: delivery_option.id)
    end
  end

  def destroy
    @delivery_option.destroy
    redirect_to admin_delivery_options_path
  end

  def delete_delivery_options
    DeliveryOption.where(id: params['ids'].split(',')).destroy_all
    redirect_to admin_delivery_options_path
  end

  private

  def delivery_option_params
    params.require(:delivery_option).permit(:name, :processing_time, :delivery_time)
  end

  def set_delivery_option
    @delivery_option = DeliveryOption.find(params[:id])
  end
  
end
