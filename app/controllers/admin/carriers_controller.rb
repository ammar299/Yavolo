class Admin::CarriersController < Admin::BaseController
  before_action :set_carrier, only: %i[edit update confirm_delete destroy]

  def new
    @carrier = Carrier.new
  end

  def create
    @carrier = Carrier.new(carrier_params)
    if @carrier.save
      redirect_to admin_delivery_options_path, flash: { notice: "Carrier has been saved" }
    else
      flash.now[:notice] =  @carrier.errors.full_messages.join('')
      render :new
    end
  end

  def update
    if @carrier.update(carrier_params)
      redirect_to admin_delivery_options_path, flash: { notice: 'Carrier has been updated' }
    else
      flash.now[:notice] =  @carrier.errors.full_messages.join('')
      render :edit
    end
  end

  def destroy
    @carrier.destroy
    redirect_to admin_delivery_options_path, flash: { alert: "Carrier has been deleted" }
  end

  def delete_carriers
    Carrier.where(id: params['ids'].split(',')).destroy_all
    @carriers = Carrier.all
    flash.now[:notice] = 'Carriers has been deleted'
  end

  private

  def carrier_params
    params.require(:carrier).permit(:name, :api_key, :secret_key)
  end

  def set_carrier
    @carrier = Carrier.find(params[:id])
  end
end
