class Buyers::CartController < Buyers::BaseController
  skip_before_action :authenticate_buyer!
  # around_action :sub_total, only: %i[cart]

  layout 'buyers/buyer'

  def cart
    @cart = get_cart
    product_ids = @cart.map { |item| item[:product_id] }
    @products = Product.find(product_ids) || []
    if !@cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
    end
    @order_amount = order_amount
    @selected_payment_method = get_selected_payment_method
  end

  def store_front; end

  def add_to_cart
    product = add_to_cart_params
    cart = []
    found = false
    if !session[:_current_user_cart].present?
      cart.push({ product_id: product[:product_id], quantity: product[:quantity].present? ? product[:quantity] : 1, added_on: DateTime.now() });
    else
      cart = session[:_current_user_cart]
      cart.each do |item|
        if item[:product_id] == product[:product_id]
          item[:quantity] = product[:quantity].present? ? product[:quantity].to_i : item[:quantity].to_i + 1
          found = true
        end
      end
      if !found
        cart.push({ product_id: product[:product_id], quantity: product[:quantity].present? ? product[:quantity] : 1, added_on: DateTime.now() });
      end
    end
    flash.now[:notice] = I18n.t('flash_messages.product_added_to_cart')
    session[:_current_user_cart] = cart
  end

  # def update_product_quantity
  #   product_params = update_product_quantity_params
  #   # todo only update if the product status is active
  #   # add status: :active in find_by
  #   @product = Product.find_by(id: product_params[:product_id])
  #   @cart_item = ''
  #   if @product.present?
  #     @cart = get_cart
  #     @cart.each do |item|
  #       if item[:product_id].to_i == @product.id
  #         @cart_item = item
  #         if product_params[:action] == 'increase' && @product.stock >= (item[:quantity]+1)
  #           item[:quantity] = item[:quantity] + 1
  #         else # else if the coming param is decrease
  #           if (item[:quantity] - 1) < 1
  #             # remove this item from session[:_current_user_cart]
  #             @cart.delete_if { |h| h[:product_id].to_i == @product.id }
  #           else
  #             item[:quantity] = item[:quantity] - 1
  #           end
  #         # else
  #           # show notice something went wrong
  #           # break
  #         end
  #       end
  #     end
  #     session[:_current_user_cart] = @cart
  #   else
  #     # show notice something went wrong
  #     return
  #   end
  # end

  def update_product_quantity_by_number
    update_product_quantity_by_number = update_product_quantity_by_number_params
    # todo only update if the product status is active
    # add status: :active in find_by
    @product = Product.find_by(id: update_product_quantity_by_number[:product_id]) || nil
    @cart = ''
    @cart_item = ''
    if @product.present?
      @cart = get_cart
      if update_product_quantity_by_number[:quantity].to_i < 1
        @cart.delete_if { |h| h[:product_id].to_i == @product.id }
        flash.now[:notice] = I18n.t('flash_messages.all_products_removed_from_cart')
        render :remove_product_form_cart
      else
        @cart.map { |h|
          if h[:product_id].to_i == @product.id
            @cart_item = h
            h[:quantity] = update_product_quantity_by_number[:quantity].to_i
          end
        }
        @order_amount = order_amount
        flash.now[:notice] = I18n.t('flash_messages.products_quantity_updated_successfully')
      end
    end
  end

  def remove_product_form_cart
    remove_product_params = remove_product_from_cart_params
    # todo only update if the product status is active
    # add status: :active in find_by
    @product = Product.find_by(id: remove_product_params[:product_id]) || nil
    if @product.present?
      @cart = get_cart
      @cart.delete_if { |h| h[:product_id].to_i == @product.id }
      @order_amount = order_amount
      flash.now[:notice] = I18n.t('flash_messages.product_removed_successfully')
    end
  end

  def update_selected_payment_method
    # session.delete(:_selected_payment_method) if params[:pay_with].present?
    session[:_selected_payment_method] = params[:pay_with] if params[:pay_with].present?
  end

  private

  def order_amount
    { total: total, sub_total: sub_total }
  end

  def sub_total
    cart = get_cart
    @sub_total = 0
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) || nil
      @sub_total += (item[:quantity].to_i * product.price.to_f) if product.price.present?
    end
    @sub_total.to_f
  end

  def total
    cart = get_cart
    @total = 0
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) || nil
      @total += item[:quantity].to_i * product.price.to_f if product.present?
    end
    @total.to_f
  end

  def get_cart
    @cart = session[:_current_user_cart] ||= []
  end

  def get_selected_payment_method
    @selected_payment_method = session[:_selected_payment_method] ||= nil
  end

  def add_to_cart_params
    params.require(:product).permit(:product_id, :quantity)
  end

  def update_product_quantity_params
    params.require(:product_quantity).permit(:product_id, :action)
  end

  def update_product_quantity_by_number_params
    params.require(:product_quantity).permit(:product_id, :quantity)
  end

  def remove_product_from_cart_params
    params.require(:remove_product).permit(:product_id)
  end
end
