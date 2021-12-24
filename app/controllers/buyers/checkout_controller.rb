class Buyers::CheckoutController < Buyers::BaseController
  skip_before_action :authenticate_buyer!
  # before_action :find_or_create_buyer, only: [:new, :create_checkout]
  before_action :get_order, only: [:new, :create_checkout, :create_payment_method, :review_order, :create_payment,
                                   :create_google_payment, :confirm_google_pay_payment, :create_paypal_order,
                                   :capture_paypal_order]

  def index; end

  def new
    @cart = get_cart
    unless @cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
      return
    end
    @order_amount = order_amount
    if @order_id.present?
      unless @order.present?
        session.delete(:_current_user_order_id)
        @order = Order.new
      end
    else
      @order = Order.new
    end
  end

  def create_checkout
    order_line_item_params = order_params
    if params[:billing_address_is_shipping_address].present? && params[:billing_address_is_shipping_address] == "true"
      order_line_item_params[:shipping_address_attributes] = order_line_item_params[:billing_address_attributes]
    end
    @order = @order.destroy if @order_id.present?
    @buyer = find_or_create_buyer(order_params[:order_detail_attributes][:email])
    @order = @buyer.orders.create(order_line_item_params)
    session[:_current_user_order_id] = @order.id
    redirect_to payment_method_path
  end

  def payment_method
    @total_num_of_products = 0
    @cart = get_cart
    @order_amount = order_amount
    unless @cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
    end
    @total_num_of_products = @cart.inject(0) { |sum, p| sum + p[:quantity] }
    # @cart.each_with_index do |value, index| 
    #   @total_num_of_products = @total_num_of_products + value[:quantity]
    # end
  end

  def create_payment_method
    if @order_id.present?
      @buyer = @order.buyer if @order.present?
      if @order.present? && @buyer.present?
        card_details = Stripe::RetrieveCardFromToken.call(
          { stripe_token_id: params[:stripeToken], buyer: @buyer }
        )
        customer = Stripe::CustomerCreator.call(
          { stripe_token_id: params[:stripeToken], buyer: @buyer }
        )
        if card_details.status
          @save_card = false
          @save_card = true if params[:is_card_saved].present? && params[:is_card_saved] == 'on'
          card = card_details.response.card
          @payment_method = update_or_create_buyer_payment_method(@buyer, params[:stripeToken], card, @save_card)
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
    if @order_id.present?
      @cart = get_cart
      @order_amount = order_amount
      product_ids = @cart.map { |item| item[:product_id] }
      @products = Product.find(product_ids) rescue []
    else
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
    end
  end

  def order_completed
    @order = Order.find params[:order]
    @line_items = @order.line_items.includes(:product)
    product_ids = @order.line_items.map { |item| item[:product_id] }
    @order_amount = order_amount
    @sub_total = @order_amount[:sub_total]
  end

  def create_payment
    if @order_id.present?
      @buyer = @order.buyer if @order.present?
      if @order.present? && @buyer.present? && @order.order_type != 'paid_order'
        @order_amount = order_amount
        payment_method = @buyer.buyer_payment_methods.last
        seller_grouped_products_hash = Stripe::SellerProductHash.call(
          { stripe_token_id: payment_method.token, buyer: @buyer, order: @order, amount: @order_amount[:total] }
        )
        unless seller_grouped_products_hash.status
          flash[:notice] = "Can't place this order. One of the sellers does not have any bank account attached yet."
          redirect_to review_order_path
          return
        end
        charge = Stripe::ChargeCreator.call(
          { stripe_token_id: payment_method.token, buyer: @buyer, order: @order, amount: @order_amount[:total] }
        )
        if charge.status
          Stripe::TransferAmount.call(
            { charge_id: charge.charge.id, seller_hash: seller_grouped_products_hash.seller_hash }
          )
          @order.update(order_type: :paid_order, buyer_payment_method_id: payment_method.id,
                        sub_total: @order_amount[:sub_total], total: @order_amount[:total])
          @order.create_payment_mode(
            payment_through: 'stripe',
            charge_id: charge.charge[:id],
            amount: charge.charge[:amount],
            return_url: charge.charge[:refunds][:url],
            receipt_url: charge.charge[:receipt_url]
          )
          session.delete(:_current_user_cart)
          session.delete(:_current_user_order_id)
          session.delete(:_selected_payment_method)
          flash[:notice] = I18n.t('flash_messages.order_placed_successfully')
          redirect_to order_completed_path(order: @order)
        else
          flash[:notice] = charge.errors
          redirect_to review_order_path
        end
      end
    end
  end

  def create_google_payment
    @order = Order.new unless @order.present?
    if @order.order_type != 'paid_order'
      @order_amount = order_amount
      # This API endpoint renders back JSON with the client_secret for the payment
      # intent so that the payment can be confirmed on the front-end. Once payment
      # is successful, fulfillment is done in the /webhook handler below.
      intent = Stripe::PaymentIntent.create({ amount: (@order_amount[:total] * 100).to_i, currency: 'gbp' })
      @buyer = @order.buyer
      unless @buyer.present?
        buyer_email = params[:buyerDetails][:buyerEmail]
        @buyer = find_or_create_buyer(buyer_email)
      end
      @payment_method = @buyer.buyer_payment_methods.create(
        payment_method_type: :google_pay,
        token: intent.id
      )
      @order.update(buyer_payment_method_id: @payment_method.id, buyer_id: @buyer.id) if @order.id.present?
      @order = Order.create(buyer_payment_method_id: @payment_method.id, buyer_id: @buyer.id) unless @order.id.present?
      @order.line_items.destroy_all if @order.line_items.present?
      @order.line_items.create(session[:_current_user_cart])
      session[:_current_user_order_id] = @order.id
      puts intent
      render json: { clientSecret: intent.client_secret }, status: :ok
    end
  end

  def confirm_google_pay_payment
    response = params
    if @order.present? && @order.order_type != 'paid_order'
      @buyer = @order.buyer
      @order_amount = order_amount
      if session_selected_payment_method.present? && session_selected_payment_method == 'g-pay'
        buyer_details = params[:buyerDetails]
        payment_method = buyer_details[:paymentMethod]
        buyer_billing_address = payment_method[:billing_details][:address]
        buyer_shipping_address = buyer_details[:shippingDetails]
        unless @order.order_detail.present?
          @order.create_order_detail(
            name: buyer_details[:buyerName],
            email: buyer_details[:buyerEmail],
            contact_number: buyer_details[:buyerPhone] || nil
          )
        end
        unless @order.shipping_address.present?
          create_gpay_shipping_address(@order, buyer_shipping_address)
        end
        unless @order.billing_address.present?
          create_gpay_billing_address(@order, buyer_billing_address)
        end
        @order = update_order_to_paid(@order, @order_amount[:total], @order_amount[:sub_total])
        create_gpay_payment_mode(@order, response, @order_amount)
        session.delete(:_current_user_cart)
        session.delete(:_current_user_order_id)
        session.delete(:_selected_payment_method)
        render json: { order: @order }, status: :ok
      end
    end
  end

  def create_paypal_order
    # PAYPAL CREATE ORDER
    unless @order.present?
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
        @order = Order.create(buyer_payment_method_id: @payment_method.id) unless @order.id.present?
        @order.line_items.destroy_all if @order.line_items.present?
        @order.line_items.create(session[:_current_user_cart])
        session[:_current_user_order_id] = @order.id
        puts paypal_order_creator
        render json: { token: paypal_order_creator.paypal_response.result.id }, status: :ok
      end
    end
  end

  def capture_paypal_order
    # PAYPAL CAPTURE ORDER
    if @order_id.present?
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
          unless @buyer.present?
            @buyer = find_or_create_buyer(payer_info.email_address)
            @order.update(buyer_id: @buyer.id)
            @order.buyer_payment_method.update(buyer_id: @buyer.id)
          end
          @order = update_order_to_paid(@order, @order_amount[:total], @order_amount[:sub_total])
          create_payment_mode_paypal(@order, paypal_order_capturor.paypal_response, @order_amount)
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

  def create_address_from_gpay(address)
    {
      address_line_1: address[:line1],
      address_line_2: address[:line2],
      city: address[:city],
      county: address[:state],
      country: address[:country],
      postal_code: address[:postal_code]
    }
  end

  def create_shipping_address_from_gpay(address)
    {
      address_line_1: address[:addressLine][0] || '',
      address_line_2: address[:addressLine][1] || address[:addressLine][0],
      city: address[:city],
      county: address[:region],
      country: address[:country],
      postal_code: address[:postalCode]
    }
  end

  def address_params(address)
    {
      address_line_1: address.address_line_1,
      address_line_2: address.address_line_2,
      city: address.admin_area_2,
      county: address.admin_area_1,
      country: address.country_code,
      postal_code: address.postal_code
    }
  end

  def create_gpay_shipping_address(order, shipping_address)
    order.create_shipping_address(create_shipping_address_from_gpay(shipping_address))
  end

  def create_gpay_billing_address(order, billing_address)
    order.create_billing_address(create_address_from_gpay(billing_address))
  end

  def create_shipping_address(order, shipping_address)
    order.create_shipping_address(address_params(shipping_address))
  end

  def create_billing_address(order, billing_address)
    order.create_billing_address(address_params(billing_address))
  end

  def update_order_to_paid(order, total, sub_total)
    order.update(
      sub_total: sub_total,
      total: total,
      order_type: :paid_order
    )
    order
  end

  def create_gpay_payment_mode(order, response, order_amount)
    order.create_payment_mode(
      payment_through: 'google_pay',
      charge_id: response[:paymentIntentId],
      amount: order_amount[:total]
    )
  end

  def create_payment_mode_paypal(order, paypal_response, order_amount)
    links = paypal_response.first.result.purchase_units.first.payments.captures.first.links
    order.create_payment_mode(
      payment_through: 'paypal',
      charge_id: paypal_response.first.result.id,
      amount: order_amount[:total],
      return_url: links[1].href,
      receipt_url: links[0].href
    )
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

  def find_or_create_buyer(email)
    @buyer = Buyer.find_by(email: email)
    if @buyer.nil?
      @buyer = Buyer.new({ email: email })
      @buyer.skip_password_validation = true
      @buyer.save
    end
    @buyer
  end

  def update_or_create_buyer_payment_method(buyer, stripe_token, card, is_card_saved)
    buyer_payment_method = buyer.buyer_payment_methods.where(token: stripe_token).last
    if buyer_payment_method.present?
      buyer_payment_method.update(
        last_digits: card.last4,
        card_holder_name: card.name,
        card_id: card.id,
        brand: card.brand,
        exp_month: card.exp_month,
        exp_year: card.exp_year,
        is_card_saved: is_card_saved
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
        exp_year: card.exp_year,
        is_card_saved: is_card_saved
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
    session[:_current_user_order_id] rescue nil
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

  def get_order
    @order_id = session_order_id
    @order = Order.find(@order_id) rescue nil
  end
end
