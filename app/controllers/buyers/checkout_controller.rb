class Buyers::CheckoutController < Buyers::BaseController
  layout 'buyers/checkout/buyer_checkout'
  skip_before_action :authenticate_buyer!
  # before_action :find_or_create_buyer, only: [:new, :create_checkout]
  before_action :get_order, only: [:new, :create_checkout, :create_payment_method, :review_order, :create_payment,
                                   :create_google_payment, :confirm_google_pay_payment, :create_paypal_order,
                                   :capture_paypal_order]

  def index; end

  def new
    @cart = get_cart
    @total_num_of_products = 0
    unless @cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
      return
    end
    @order_amount = order_amount
    @total_num_of_products = @cart.inject(0) { |sum, p| sum + p[:quantity].to_i }
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
    @order = @order.destroy if @order_id.present?
    @buyer = find_or_create_buyer(order_params[:order_detail_attributes][:email])
    @order = @buyer.orders.create(order_params.except(order_params[:shipping_address_attributes], order_params[:billing_address_attributes]))
    update_billing_shipping_addresses(@order)
    session[:_current_user_order_id] = @order.id
    redirect_to payment_method_path
  end

  def update_billing_shipping_addresses(order)
    if order.billing_address_is_shipping_address
      order.shipping_address.update_columns(order_params[:order_detail_attributes].except(:email, :phone_number).to_h)
      order.billing_address.update_columns(order_params[:order_detail_attributes].except(:email, :phone_number).to_h)
    else
      order.shipping_address.update_columns(order_params[:order_detail_attributes].except(:email, :phone_number).to_h)
    end
  end

  def payment_method
    @total_num_of_products = 0
    @cart = get_cart
    @order_amount = order_amount
    unless @cart.present?
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
    end
    @total_num_of_products = @cart.inject(0) { |sum, p| sum + p[:quantity].to_i }
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
    @total_num_of_products = 0
    if @order_id.present?
      @cart = get_cart
      @order_amount = order_amount
      product_ids = @cart.map { |item| item[:product_id] }
      @products = Product.find(product_ids) rescue []
    else
      flash[:notice] = I18n.t('flash_messages.no_products_are_added_to_card')
      redirect_to store_front_path
    end
    @total_num_of_products = @cart.inject(0) { |sum, p| sum + p[:quantity].to_i }
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
          @total_commission = seller_grouped_products_hash.seller_hash.sum {|h| h[:total_commissioned_amount] }
          @total_remaining_amount = seller_grouped_products_hash.seller_hash.sum {|h| h[:remaining_amount] }
          @order.update(order_type: :paid_order, buyer_payment_method_id: payment_method.id,
                        sub_total: @order_amount[:sub_total], total: @order_amount[:total],
                        commission: @total_commission, remaining_price: @total_remaining_amount)
          @order.create_payment_mode(
            payment_through: 'stripe',
            charge_id: charge.charge[:id],
            amount: charge.charge[:amount],
            return_url: charge.charge[:refunds][:url],
            receipt_url: charge.charge[:receipt_url]
          )
          update_line_items_quantity_after_order(@order)
          reduce_cart_products_stock(session[:_current_user_cart])
          clear_session
          flash[:notice] = I18n.t('flash_messages.order_placed_successfully')
          OrderMailer.with(to: @buyer.email).send_order_complete_mail.deliver_now
          redirect_to order_completed_path(order: @order)
        else
          flash[:notice] = charge.errors
          redirect_to review_order_path
        end
      end
    end
  end

  def paypal_payout_webhook
    if params.present?
      batch_payout_id = params[:resource][:batch_header][:payout_batch_id]
      if batch_payout_id.present?
        LineItem.where(transfer_id: batch_payout_id).update(transfer_status: :paid)
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
        buyer_billing_details = payment_method[:billing_details]
        buyer_billing_address = payment_method[:billing_details][:address]
        buyer_shipping_address = buyer_details[:shippingDetails]
        buyer_billing_address_payload = {
          first_name: buyer_billing_details[:name].split(' ')[0] || '',
          last_name: buyer_billing_details[:name].split(' ', 2).last || buyer_billing_details[:name].split(' ')[0] || '',
          address_line_1: buyer_billing_address[:line1],
          address_line_2: buyer_billing_address[:line2],
          city: buyer_billing_address[:city],
          county: buyer_billing_address[:state],
          country: buyer_billing_address[:country],
          postal_code: buyer_billing_address[:postal_code]
        }
        buyer_shipping_address_payload = {
          first_name: buyer_shipping_address[:recipient].split(' ')[0] || '',
          last_name: buyer_shipping_address[:recipient].split(' ', 2).last || buyer_shipping_address[:recipient].split(' ')[0] || '',
          address_line_1: buyer_shipping_address[:addressLine][0].split[0] || '',
          address_line_2: buyer_shipping_address[:addressLine][0].split(' ', 2).last || '',
          city: buyer_shipping_address[:city],
          county: buyer_shipping_address[:region],
          country: buyer_shipping_address[:country],
          postal_code: buyer_shipping_address[:postalCode]
        }
        unless @order.order_detail.present?
          @order.create_order_detail(
            first_name: buyer_details[:buyerName].split(' ')[0] || '',
            last_name: buyer_details[:buyerName].split(' ', 2).last || buyer_details[:buyerName].split(' ')[0] || '',
            email: buyer_details[:buyerEmail],
            phone_number: buyer_details[:buyerPhone] || nil
          )
        end
        unless @order.shipping_address.present?
          create_gpay_shipping_address(@order, buyer_shipping_address_payload)
        end
        unless @order.billing_address.present?
          create_gpay_billing_address(@order, buyer_billing_address_payload)
        end
        @order = update_order_to_paid(@order, @order_amount[:total], @order_amount[:sub_total])
        update_line_items_quantity_after_order(@order)
        create_gpay_payment_mode(@order, response, @order_amount)
        reduce_cart_products_stock(session[:_current_user_cart])
        clear_session
        OrderMailer.with(to: @buyer.email).send_order_complete_mail.deliver_now
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
      seller_grouped_products_hash = Stripe::SellerProductHash.call(
        { order: @order }
      )
      unless seller_grouped_products_hash.status
        flash[:notice] = "Can't place this order. One of the sellers does not have paypal attached."
        redirect_to store_front_path
        return
      end
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
          create_paypal_payout(@order)
          payer_info = paypal_order_capturor.paypal_response.first.result.payer
          if session_selected_payment_method.present? && session_selected_payment_method == 'paypal' && !@order.order_detail.present?
            billing_address_obj_length = Paypal::PaypalResponse.parsed_response(payer_info.address)
            billing_address = payer_info
            @order.create_order_detail(
              first_name: payer_info.name.given_name,
              last_name: payer_info.name.surname,
              email: payer_info.email_address,
              phone_number: payer_info.try(:phone).try(:phone_number).try(:national_number) || nil
            )
            shipping_address = paypal_order_capturor.paypal_response.first.result.purchase_units.first.shipping
            create_shipping_address(@order, shipping_address)
            billing_address[:name] = {'full_name': "#{billing_address.name.give_name} #{billing_address.name.surname}"}
            create_billing_address(@order, billing_address_obj_length.length > 2 ? billing_address : shipping_address)
          end
          unless @buyer.present?
            @buyer = find_or_create_buyer(payer_info.email_address)
            @order.update(buyer_id: @buyer.id)
            @order.buyer_payment_method.update(buyer_id: @buyer.id)
          end
          @order = update_order_to_paid(@order, @order_amount[:total], @order_amount[:sub_total])
          update_line_items_quantity_after_order(@order)
          create_payment_mode_paypal(@order, paypal_order_capturor.paypal_response, @order_amount)
          reduce_cart_products_stock(session[:_current_user_cart])
          clear_session
          OrderMailer.with(to: @buyer.email).send_order_complete_mail.deliver_now
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

  def clear_session
    session.delete(:_current_user_cart)
    session.delete(:_current_user_order_id)
    session.delete(:_selected_payment_method)
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

  def address_params_from_paypal(address)
    name = address.name.full_name.split(' ',2)
    address = address.address
    {
      first_name: name.first,
      last_name: name.last,
      address_line_1: address.address_line_1,
      address_line_2: address.address_line_2,
      city: address.admin_area_2,
      county: address.admin_area_1,
      country: address.country_code,
      postal_code: address.postal_code
    }
  end

  def create_gpay_shipping_address(order, shipping_address)
    order.create_shipping_address(shipping_address)
  end

  def create_gpay_billing_address(order, billing_address)
    order.create_billing_address(billing_address)
  end

  def create_shipping_address(order, shipping_address)
    order.create_shipping_address(address_params_from_paypal(shipping_address))
  end

  def create_billing_address(order, billing_address)
    order.create_billing_address(address_params_from_paypal(billing_address))
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
    @buyer = Buyer.find_by(email: email.downcase)
    if @buyer.nil?
      @buyer = Buyer.new({ email: email })
      @buyer.skip_password_validation = true
      @buyer.save(validate: false)
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

  def fname_lname_in_ship_bill_addr(order)
    if order.present?
      order.shipping_address.update(first_name: order.order_detail&.first_name, last_name: order.order_detail&.last_name)
      order.billing_address.update(first_name: order.order_detail&.first_name, last_name: order.order_detail&.last_name)
    end
  end

  def update_line_items_quantity_after_order(order)
    # session[:_current_user_cart] = [{:product_id=>"4", :quantity=>1, :added_on=>Mon, 17 Jan 2022 13:57:36 +0500}]
    order.line_items.each do |line_item|
      session_item = session[:_current_user_cart].select { |ar| ar[:product_id].to_i == line_item[:product_id].to_i }.first
      if session_item.present? && line_item[:product_id].to_i == session_item[:product_id].to_i
        line_item.update(quantity: session_item[:quantity].to_i, transfer_status: :paid)
      end
    end
  end


  def create_paypal_payout(order)
    seller_grouped_products_hash = Stripe::SellerProductHash.call(
      { order: order }
    )
    if seller_grouped_products_hash.status
      response = Paypal::PayoutCreator.call({ debug: true, seller_hash: seller_grouped_products_hash.seller_hash })
      if response.status
        update_line_items_status(order, response.paypal_payout_response.result.batch_header.payout_batch_id, seller_grouped_products_hash.seller_hash)
      end
    end
  end

  def update_line_items_status(order, transfer_id, seller_hash = nil)
    unless seller_hash.present?
      seller_grouped_products_hash = Stripe::SellerProductHash.call(
        { order: order }
      )
      if seller_grouped_products_hash.status
        seller_hash = seller_grouped_products_hash.seller_hash
      else
        return
      end
    end
    seller_hash.each do |seller_details|
      Orders::UpdateLineItemsToPaid.call(
        { seller_id: seller_details[:seller_id], transfer_id: transfer_id,
          transfer_status: 'pending', products_array: seller_details[:products_array] }
      )
    end
  end

  def save_stripe_customer_detail(buyer, customer)
    if buyer.stripe_customer.present?
      buyer.stripe_customer.update(customer_id: customer.id)
    else
      buyer.create_stripe_customer(customer_id: customer.id)
    end
  end

  def reduce_cart_products_stock(cart)
    cart.each do |item|
      reduce_product_stock(item[:product_id], item[:quantity].to_i)
    end
  end

  def reduce_product_stock(product_id, quantity)
    product = Product.find_by(id: product_id)
    return unless product.present?

    decremented_stock_value = product.stock.to_i - quantity
    product.update(stock: decremented_stock_value)
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
    params.require(:order).permit(:billing_address_is_shipping_address,
      order_detail_attributes: [:id, :first_name, :last_name, :phone_number, :email, :_destroy],
      billing_address_attributes: [:id, :first_name, :last_name, :company_name, :appartment, :address_line_1, :address_line_2, :city, :county, :country, :postal_code],
      shipping_address_attributes: [:id, :first_name, :last_name, :company_name, :appartment, :address_line_1, :address_line_2, :city, :county, :country, :postal_code],
      line_items_attributes: [:id, :product_id, :quantity, :added_on]
    )
  end

  def get_order
    @order_id = session_order_id
    @order = Order.find(@order_id) rescue nil
  end
end
