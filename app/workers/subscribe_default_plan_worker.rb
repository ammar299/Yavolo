class SubscribeDefaultPlanWorker
  include Sidekiq::Worker

  def perform(*args)
    seller = args[0]
    current_seller = Seller.find_by(email: seller)
    unless !current_seller.present?
      if !current_seller.seller_stripe_subscription.present?
        @subscribe = Sellers::StripeDefaultSubscriptionCreatorService.call({seller: current_seller}) 
      end
    end
  end

end
