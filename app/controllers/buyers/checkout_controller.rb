class Buyers::CheckoutController < Buyers::BaseController
  skip_before_action :authenticate_buyer!
  # before_action :find_or_create_buyer, only: [:new, :create_checkout]

  def index; end

  def new
    @cart = get_cart
    if !@cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
      return
    end
    @order_amount = order_amount
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id) || nil
      session.delete(:_current_user_order_id) if !@order.present?
      @order = Order.new if !@order.present?
    else
      @order = Order.new
    end
  end

  def create_checkout
    order_line_item_params = order_params
    if params[:billing_address_is_shipping_address].present? && params[:billing_address_is_shipping_address] == "true"
      order_line_item_params[:shipping_address_attributes] = order_line_item_params[:billing_address_attributes]
    end
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id).destroy
    end
    @buyer = find_or_create_buyer(order_params[:order_detail_attributes][:email])
    @order = @buyer.orders.create(order_line_item_params)
    session[:_current_user_order_id] = @order.id
    redirect_to payment_method_path
  end

  def payment_method
    @cart = get_cart
    @order_amount = order_amount
    if !@cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
    end
  end

  def create_payment_method
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id)
      @buyer = @order.buyer if @order.present?
      if @order.present? && @buyer.present?
        card_details = Stripe::RetrieveCardFromToken.call(
          { stripe_token_id: params[:stripeToken], buyer: @buyer }
        )
        customer = Stripe::CustomerCreator.call(
          { stripe_token_id: params[:stripeToken], buyer: @buyer }
        )
        if card_details.status
          card = card_details.response.card
          @payment_method = update_or_create_buyer_payment_method(@buyer, params[:stripeToken], card)
          @order.update(buyer_payment_method_id: @payment_method.id)
        end
        if customer.status
          save_stripe_customer_detail(@buyer, customer.response)
          flash[:notice] = 'Card added successfully.'
          redirect_to review_order_path
        else
          flash[:notice] = customer.errors
          render :payment_method
        end
      end
    end
  end

  def review_order
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id)
      @cart = get_cart
      @order_amount = order_amount
      product_ids = @cart.map { |item| item[:product_id] }
      @products = Product.find(product_ids) || []
    else
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
    end
  end

  def order_completed
    @order = Order.find params[:order]
    @line_items = @order.line_items.includes(:product)
    product_ids = @order.line_items.map { |item| item[:product_id] }
    @sub_total = 0
    product_ids.each do |item|
      product = Product.find(item.to_i) || nil
      @sub_total += (product.price.to_f) if product.present?
    end
    @sub_total.to_f
  end

  def create_payment
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id)
      @buyer = @order.buyer if @order.present?
      if @order.present? && @buyer.present? && @order.order_type != 'paid_order'
        @order_amount = order_amount
        payment_method = @buyer.buyer_payment_methods.last
        payment = Stripe::ChargeCreator.call(
          { stripe_token_id: payment_method.token, buyer: @buyer, order: @order, amount: @order_amount[:total] }
        )
        if payment.status
          @order.update(buyer_payment_method_id: payment_method.id,sub_total: @order_amount[:sub_total],total: @order_amount[:total])
          session.delete(:_current_user_cart)
          session.delete(:_current_user_order_id)
          session.delete(:_selected_payment_method)
          flash[:notice] = I18n.t('flash_messages.order_placed_successfully')
          redirect_to order_completed_path(order: @order)
        else
          flash[:notice] = payment.errors
          render :review_order
        end
      end
    end
  end

  def create_paypal_order
    # PAYPAL CREATE ORDER
    @order = Order.find(session_order_id) rescue nil
    if !@order.present?
      @order = Order.new
    end
    if @order.order_type != 'paid_order'
      paypal_order_creator = Paypal::PaypalOrderCreator.call({ debug: true, amount: order_amount[:total] })
      if paypal_order_creator.status
        @buyer = @order.buyer
        if @buyer.present?
          @payment_method = @buyer.buyer_payment_methods.create(
            payment_method_type: :paypal,
            token: paypal_order_creator.paypal_response.result.id
          )
        else
          @payment_method = BuyerPaymentMethod.create(
            payment_method_type: :paypal,
            token: paypal_order_creator.paypal_response.result.id
          )
        end
        @order.update(buyer_payment_method_id: @payment_method.id) if @order.id.present?
        @order = Order.create(buyer_payment_method_id: @payment_method.id) if !@order.id.present?
        session[:_current_user_order_id] = @order.id
        puts paypal_order_creator
        render json: { token: paypal_order_creator.paypal_response.result.id }, status: :ok
      end
    end
  end

  def capture_paypal_order
    # PAYPAL CAPTURE ORDER
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id)
      @buyer = @order.buyer if @order.present?
      if @order.present? && @order.order_type != 'paid_order'
        @order_amount = order_amount
        paypal_order_capturor = Paypal::PaypalOrderCapturor.call({ order_id: params[:order_id], debug: true })
        if paypal_order_capturor.status
          payer_info = paypal_order_capturor.paypal_response.first.result.payer
          if session_selected_payment_method.present? && session_selected_payment_method == 'paypal' && !@order.order_detail.present?
            billing_address = payer_info.address
            @order.create_order_detail(
              name: payer_info.name.given_name,
              email: payer_info.email_address,
              contact_number: payer_info.try(:phone).try(:phone_number).try(:national_number) || nil
            )
            shipping_address = paypal_order_capturor.paypal_response.first.result.purchase_units.first.shipping.address
            create_shipping_address(@order, shipping_address)
            create_billing_address(@order, billing_address)
          end
          if !@buyer.present?
            @buyer = find_or_create_buyer(payer_info.email_address)
            @order.buyer_payment_method.update(buyer_id: @buyer.id)
          end
          update_order_to_paid(@order, @order_amount[:total], @order_amount[:sub_total])
          create_payment_mode_paypal(@order, paypal_order_capturor.paypal_response)
          puts paypal_order_capturor.paypal_response
          session.delete(:_current_user_cart)
          session.delete(:_current_user_order_id)
          session.delete(:_selected_payment_method)
          render json: { status: paypal_order_capturor.paypal_response[0].result.status, order: @order }, status: :ok
        end
      end
    end
  end

  private

  def get_cart
    session[:_current_user_cart] ||= []
  end

  def order_amount
    { total: total, sub_total: sub_total }
  end

  def session_selected_payment_method
    session[:_selected_payment_method] || nil
  end

  def create_shipping_address(order, shipping_address)
    order.create_shipping_address(
      address_line_1: shipping_address.address_line_1,
      address_line_2: shipping_address.address_line_2,
      city: shipping_address.admin_area_2,
      county: shipping_address.admin_area_1,
      country: shipping_address.country_code,
      postal_code: shipping_address.postal_code
    )
  end

  def create_billing_address(order, billing_address)
    order.create_billing_address(
      address_line_1: billing_address.address_line_1,
      address_line_2: billing_address.address_line_2,
      city: billing_address.admin_area_2,
      county: billing_address.admin_area_1,
      country: billing_address.country_code,
      postal_code: billing_address.postal_code
    )
  end

  def update_order_to_paid(order, total, sub_total)
    order.update(
      sub_total: sub_total,
      total: total,
      order_type: :paid_order
    )
  end

  def create_payment_mode_paypal(order, paypal_response)
    links = paypal_response.first.result.purchase_units.first.payments.captures.first
    order.create_payment_mode(
      payment_through: 'paypal',
      charge_id: paypal_response.result.id,
      amount: @order_amount[:total],
      return_url: links[1].href,
      receipt_url: links[0].href
    )
  end

  def sub_total
    cart = get_cart
    @sub_total = 0
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) || nil
      @sub_total += (item[:quantity].to_i * product.price.to_f) if product.present?
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

  def find_or_create_buyer(email)
    @buyer = Buyer.find_by(email: email)
    if @buyer.nil?
      @buyer = Buyer.new({ email: email })
      @buyer.skip_password_validation = true
      @buyer.save
    end
    @buyer
  end

  def update_or_create_buyer_payment_method(buyer, stripe_token, card)
    buyer_payment_method = buyer.buyer_payment_methods.where(token: stripe_token).last
    if buyer_payment_method.present?
      buyer_payment_method.update(
        last_digits: card.last4,
        card_holder_name: card.name,
        card_id: card.id,
        brand: card.brand,
        exp_month: card.exp_month,
        exp_year: card.exp_year
      )
    else
      buyer_payment_method = buyer.buyer_payment_methods.create(
        payment_method_type: :stripe,
        token: stripe_token,
        last_digits: card.last4,
        card_holder_name: card.name,
        card_id: card.id,
        brand: card.brand,
        exp_month: card.exp_month,
        exp_year: card.exp_year
      )
    end
    buyer_payment_method
  end

  def save_stripe_customer_detail(buyer, customer)
    if buyer.stripe_customer.present?
      buyer.stripe_customer.update(customer_id: customer.id)
    else
      buyer.create_stripe_customer(customer_id: customer.id)
    end
  end

  def session_order_id
    session[:_current_user_order_id] || nil
  end

  def line_items_params
    line_items = session[:_current_user_cart]
    params[:order].merge!({line_items_attributes: line_items})
  end

  def order_params
    line_items_params
    params.require(:order).permit(
      order_detail_attributes: [:id, :name, :contact_number, :email, :_destroy],
      billing_address_attributes: [:id, :appartment, :address_line_1, :address_line_2, :city, :county, :country, :postal_code],
      shipping_address_attributes: [:id, :appartment, :address_line_1, :address_line_2, :city, :county, :country, :postal_code],
      line_items_attributes: [:id, :product_id, :quantity, :added_on]
    )
  end
end
