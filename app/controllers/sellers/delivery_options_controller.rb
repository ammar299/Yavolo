class Sellers::DeliveryOptionsController < Sellers::BaseController
  include DeliveryTemplateMethods

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
    # @delivery_opts = true
    # @errors = 'Template already exists!'
    # delivery_option_filtering
    @delivery_option = DeliveryOption.new(delivery_option_params.merge(handle: delivery_option_params[:name].parameterize(separator: '_')))
    # if @delivery_opts == true
    if @delivery_option.save
      # @delivery_option.save
      create_delivery_option_ships(@delivery_option)
      @delivery_options = current_seller.delivery_options
      flash.now[:notice] = 'Template has been created!'
    else
      persisted_delivery_ships
      flash.now[:notice] = @delivery_option.errors.full_messages.join('')
      render :new
    end
  end

  def update
    # @existing_obj = true
    # @delivery_opts = true
    # @errors = 'Template already exists'
    # verify_delivery_option(@delivery_option)
    # delivery_option_filtering(@delivery_option) if @existing_obj == false
    # params[:delivery_option][:ship_ids] = params[:delivery_option][:ship_ids].reject { |c| c.empty? }
    # if @existing_obj == true || @delivery_opts == true
    if @delivery_option.update(delivery_option_params.merge(handle: delivery_option_params[:name].parameterize(separator: '_')))
      @delivery_option.update(delivery_option_params)
      create_delivery_option_ships(@delivery_option)
      @delivery_options = current_seller.delivery_options
      flash.now[:notice] = 'Template has been updated!'
    else
      persisted_delivery_ships
      flash.now[:notice] = @delivery_option.errors.full_messages.join('')
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

  # def verify_delivery_option(delivery_option)
  #   if delivery_option.id == DeliveryOption.find_by(delivery_option_params)&.id
  #     filter_ship_ids
  #     @delivery_ship_array = []
  #     @filter_ship_ids_array = []
  #     comparing_delivery_template_ships(delivery_option)
  #     @existing_obj = @delivery_ship_array == @filter_ship_ids_array
  #   else
  #     @existing_obj = false
  #   end
  # end

  # def check_delivery_option_availbility(delivery_options)
  #   filter_ship_ids
  #   delivery_options.each do |delivery_option|
  #     next if delivery_option.ships.count != @selected_ships.count
  #     @delivery_ship_array = []
  #     @filter_ship_ids_array = []
  #     comparing_delivery_template_ships(delivery_option)
  #     result = @delivery_ship_array == @filter_ship_ids_array
  #     @errors = 'Template exists in Global Templates' if result && (delivery_option.delivery_optionable_type == 'Admin')
  #     @delivery_opts = false if result
  #   end
  # end
end
