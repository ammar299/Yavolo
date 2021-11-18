class Sellers::SubscriptionsController < Sellers::BaseController
  def index; end

  def destroy
    subscription = SellerStripeSubscription.find(params[:id].to_i)
    CancelSubscriptionEmailWorker.perform_async(current_seller.email)
    current_seller.seller_stripe_subscription.update(seller_requested_cancelation: true)
    @seller = current_seller
    flash.now[:notice] = 'Subscription cancelation process started. You will be notified once completed'
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
