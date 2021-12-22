class Admin::DeliveryOptionsController < Admin::BaseController
  include DeliveryTemplateMethods

  before_action :set_delivery_option, only: %i[edit update confirm_delete destroy delete_delivery_option]
  before_action :set_seller_id, only: %i[edit new]

  def index
    @delivery_options = DeliveryOption.order(created_at: :desc)
    @carriers = Carrier.all
  end

  def new
    @delivery_option = DeliveryOption.new
  end

  def create
    # @delivery_opts = true
    # @seller_template_exists = false
    # delivery_option_filtering
    # @existing_seller_template.destroy if @seller_template_exists
    @delivery_option = DeliveryOption.new(delivery_option_params.merge(handle: delivery_option_params[:name].parameterize(separator: '_')))
    # if @delivery_opts == true || @seller_template_exists == true
    if @delivery_option.save
      # @delivery_option.save
      create_delivery_option_ships(@delivery_option)
      manage_delivery_options_list(@delivery_option)
      flash.now[:notice] = 'Template has been created!'
    else
      persisted_delivery_ships
      # flash.now[:notice] = 'Template already exists!'
      flash.now[:notice] = @delivery_option.errors.full_messages.join('')
      render :new
    end
  end

  def update
    # @existing_obj = true
    # @delivery_opts = true
    # @seller_template_exists = false
    # verify_delivery_option(@delivery_option)
    # delivery_option_filtering(@delivery_option) if @existing_obj == false
    # @existing_seller_template.destroy if @seller_template_exists
    # if @existing_obj == true || @delivery_opts == true || @seller_template_exists == true
    if @delivery_option.update(delivery_option_params.merge(handle: delivery_option_params[:name].parameterize(separator: '_')))
      # @delivery_option.update(delivery_option_params)
      create_delivery_option_ships(@delivery_option)
      manage_delivery_options_list(@delivery_option)
      flash.now[:notice] = 'Template has been updated!'
    else
      @delivery_option_name = params[:delivery_option][:name]
      persisted_delivery_ships
      # flash.now[:notice] = 'Template already exists!'
      flash.now[:notice] = @delivery_option.errors.full_messages.join('')
      render :edit
    end
  end

  def destroy
    @delivery_option.destroy
    redirect_to admin_delivery_options_path, flash: { notice: 'Template has been deleted successfully!' }
  end

  def delete_delivery_options
    DeliveryOption.where(id: params['ids'].split(',')).destroy_all
    @delivery_options = DeliveryOption.order(created_at: :desc)
    flash.now[:notice] = 'Templates has been deleted'
  end

  def delete_delivery_option
    @delivery_option.destroy
    @delivery_options = DeliveryOption.where(delivery_optionable_type: "Seller", delivery_optionable_id: @delivery_option.delivery_optionable_id)
  end

  def search_seller_delivery_options
    if params[:search].present?
      seller_id = Seller.find(params[:seller_id])
      @delivery_options = DeliveryOption.where(delivery_optionable_type: "Seller", delivery_optionable_id: seller_id).global_search(params[:search]).order(created_at: :desc)
    else 
      seller_id = Seller.find(params[:seller_id])
      @delivery_options = DeliveryOption.where(delivery_optionable_type: "Seller", delivery_optionable_id: seller_id).order(created_at: :desc)
    end
  end

  private

  def delivery_option_params
    params.require(:delivery_option).permit(:name, :ship_ids, :delivery_optionable_type, :delivery_optionable_id)
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
  #     result = @delivery_ship_array == @filter_ship_ids_array
  #     @existing_obj = result
  #     @seller_template_exists = result && (delivery_option.delivery_optionable_type == 'Seller')
  #     @existing_seller_template = delivery_option if @seller_template_exists
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
  #     @delivery_opts = false if result
  #     @seller_template_exists = result && (delivery_option.delivery_optionable_type == 'Seller')
  #     @existing_seller_template = delivery_option if @seller_template_exists
  #   end
  # end

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
end
