class Sellers::SubscriptionsController < Sellers::BaseController
  def index; end

  def remove_subscription
    notice = 'Subscription cancelation process failed.Try again later.'
    subscription = SellerStripeSubscription.find(params[:format].to_i)
    subscription.reason = params[:reason]
    if subscription.save
      CancelSubscriptionEmailWorker.perform_async(current_seller.email,params[:reason])
      current_seller.seller_stripe_subscription.update(seller_requested_cancelation: true)
      @seller = current_seller
      notice = 'Subscription cancelation process started. You will be notified once completed'
    end
    flash.now[:notice] = notice 
  end

  def get_current_subscription
    @seller = current_seller
    subscription = @seller.seller_stripe_subscription
    current_plan = @seller.get_current_plan(subscription.plan_name) if subscription.present?
    if subscription.present? && current_plan.present?
      return render json: {subscription: subscription, current_plan: current_plan, seller: @seller}, status: 200
    else
      return render json: {error: 'No Data Found'}, status: 200
    end
  end

end
