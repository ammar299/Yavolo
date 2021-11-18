class SellerPaymentMethod < ApplicationRecord
  belongs_to :seller
  
  def unset_default_methods
    seller.seller_payment_methods&.each do |payment_method|
      payment_method.default_status = false
      payment_method.save
    end
  end

  def detach_payment_method(params)
    payment_method = SellerPaymentMethod.find(params[:id]) if params[:id].present?
    token = get_source_token(payment_method)
    card = Sellers::StripeApiCallsService.detach_card(token,payment_method.seller)
    payment_method.destroy if card.deleted == true
  end

  def get_source_token(payment_method)
    source_token = Stripe::Token.retrieve(
      payment_method.stripe_token,
    )
    return source_token
  end

end