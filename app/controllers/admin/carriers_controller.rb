class Admin::CarriersController < Admin::BaseController
  before_action :set_carrier, only: %i[edit update destroy]

  def new
    @carrier = Carrier.new
  end

  def create
    @carrier = Carrier.new(carrier_params)
    if @carrier.save
      redirect_to admin_delivery_options_path
    else
      render :new
    end
  end

  def update
    if @carrier.update(carrier_params)
      redirect_to admin_delivery_options_path
    else
      render :edit
    end
  end

  def destroy
    @carrier.destroy
    redirect_to admin_delivery_options_path
  end

  def delete_carriers
    Carrier.where(id: params['ids'].split(',')).destroy_all
    redirect_to admin_delivery_options_path
  end

  private

  def carrier_params
    params.require(:carrier).permit(:name, :api_key, :secret_key)
  end

  def set_carrier
    @carrier = Carrier.find(params[:id])
  end
end
