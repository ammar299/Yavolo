class Buyers::CartController < Buyers::BaseController
  skip_before_action :authenticate_buyer!
  # around_action :sub_total, only: %i[cart]

  layout 'buyers/buyer'

  def cart
    @cart = get_cart
    if !@cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      return
    end

    @products = []
    @cart.each do |cart_item|
      product = Product.find_by(id: cart_item[:product_id])
      @cart.delete_if { |h| h[:product_id].to_i == cart_item[:product_id] } if product.blank?
      @products.push(product) if product.present?
    end
    @order_amount = order_amount
    @selected_payment_method = get_selected_payment_method
  end

  def store_front
    @products_to_display = Product.all.where(status: 'active')
  end

  def add_to_cart
    product = add_to_cart_params
    this_product = Product.find_by(id: product[:product_id])
    if !this_product.present? || this_product.present? && (this_product.owner&.bank_detail&.account_verification_status.to_s == 'false' || this_product.owner&.paypal_detail&.integration_status.to_s == 'false')
      flash.now[:notice] = I18n.t('flash_messages.cannot_buy_this_product')
      return
    end
    cart = []
    found = false
    if !session[:_current_user_cart].present?
      cart.push({ product_id: product[:product_id], quantity: product[:quantity].present? ? product[:quantity] : 1, added_on: DateTime.now() });
    else
      cart = session[:_current_user_cart]
      cart.each do |item|
        next unless item[:product_id] == product[:product_id]

        unless (item[:quantity].to_i + 1) <= this_product[:stock].to_i
          flash.now[:notice] = I18n.t('flash_messages.stock_not_available')
          return
        end
        item[:quantity] = product[:quantity].present? ? product[:quantity].to_i : item[:quantity].to_i + 1
        found = true
      end
      if !found
        cart.push({ product_id: product[:product_id], quantity: product[:quantity].present? ? product[:quantity] : 1, added_on: DateTime.now() });
      end
    end
    flash.now[:notice] = I18n.t('flash_messages.product_added_to_cart')
    session[:_current_user_cart] = cart
  end

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
        flash.now[:notice] = I18n.t('flash_messages.product_removed_successfully')
        @order_amount = order_amount
        render :remove_product_form_cart
      else
        @cart.each do |item|
          next unless item[:product_id].to_i == @product.id

          @cart_item = item
          if update_product_quantity_by_number[:quantity].to_i > @product[:stock].to_i
            flash.now[:notice] = I18n.t('flash_messages.stock_not_available')
            next
          else
            item[:quantity] = update_product_quantity_by_number[:quantity].to_i
            flash.now[:notice] = I18n.t('flash_messages.products_quantity_updated_successfully')
          end
        end
        @order_amount = order_amount
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

  def remove_product_from_summary
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
    if params[:product_count].present?
      @total_num_of_products = @cart.inject(0) { |sum, p| sum + p[:quantity].to_i }
    end
    clear_session if (@cart.length == 0)
    # redirect_to cart_path if (@total_num_of_products = 0)
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
      product = Product.find(item[:product_id].to_i) rescue nil
      @sub_total += item[:quantity].to_i * (product.price ? product.price.to_f : 0) if product.present?
    end
    @sub_total.to_f
  end

  def total
    cart = get_cart
    @total = 0
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) rescue nil
      @total += item[:quantity].to_i * (product.price ? product.price.to_f : 0) if product.present?
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

  def clear_session
    session.delete(:_current_user_cart)
    session.delete(:_current_user_order_id)
    session.delete(:_selected_payment_method)
  end

end
