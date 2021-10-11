class Admin::CarriersController < Admin::BaseController
  before_action :set_carrier, only: %i[edit update destroy]

  def new
    @carrier = Carrier.new
  end

  def create
    @carrier = Carrier.new(carrier_params)
    if @carrier.save
      @carriers = Carrier.all
    else
      render :new
    end
  end

  def update
    if @carrier.update(carrier_params)
      @carriers = Carrier.all
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
    @carriers = Carrier.all
  end

  private

  def carrier_params
    params.require(:carrier).permit(:name, :api_key, :secret_key)
  end

  def set_carrier
    @carrier = Carrier.find(params[:id])
  end
end
