class Sellers::PaymentMethodsController < Sellers::BaseController
  def index; end

  def create
    if params[:stripeToken].present?
      @seller =  current_seller
      stripe_token = params[:stripeToken]
      card = @seller.seller_payment_methods.where(stripe_token: stripe_token)
      stripe_customer if !@seller.stripe_customer.present?
      if !card.present?
        token = Sellers::StripeApiCallsService.retrieve_token(stripe_token)
        Sellers::StripeApiCallsService.attach_card_to_customer(current_seller,stripe_token)
        save_card_in_db(token)
      end    
      
      if !@seller.seller_stripe_subscription.present?
        @subscribe = Sellers::StripeDefaultSubscriptionCreatorService.call({seller: current_seller}) 
      end
      @payment_methods = current_seller.seller_payment_methods.reload
      flash.now[:notice] =  'Card added successfully!!'
    else
      return false
    end
  end

  def set_default_card 
    card = current_seller.seller_payment_methods.where(id: params[:format].to_i).last
    Sellers::StripeApiCallsService.set_card_as_default_payment(current_seller,card)
    card.unset_default_methods
    card.default_status = true
    card.save
    @payment_methods = current_seller.seller_payment_methods.reload
    if card.save == true
      flash.now[:notice] =  'Card set as default successfully!!'
    else
      flash.now[:notice] =  "Error occurred: #{card.errors}"
    end
  end

  def destroy
    payment_method = SellerPaymentMethod.find(params[:id].to_i) if params[:id].to_i.present?
    
    if payment_method.default_status == true
      @payment_methods = current_seller.seller_payment_methods.reload
      flash.now[:notice] =  'You cannot remove this card because it is selected as default. Change default card before remove!!'
    else
      payment_method.detach_payment_method(params)
      @payment_methods = current_seller.seller_payment_methods.reload
      flash.now[:notice] =  'Card removed successfully!!'
    end
  end

  private

  def save_card_in_db(token)
    if current_seller.seller_payment_methods.count == 0
      current_seller.seller_payment_methods.create(
        stripe_token: token.id,
        last_digits: token.card.last4,
        card_holder_name: token.card.name,
        card_id: token.card.id,
        default_status: true
      ) 
    else
      current_seller.seller_payment_methods.create(
        stripe_token: token.id,
        last_digits: token.card.last4,
        card_holder_name: token.card.name,
        card_id: token.card.id
      ) 
    end

  end

  def stripe_customer
    Sellers::StripeCustomerService.call({seller: current_seller})
  end
end