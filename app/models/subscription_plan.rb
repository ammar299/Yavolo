class SubscriptionPlan < ApplicationRecord
  validates :subscription_name, presence: true
  validates :price, presence: true
  validates :commission_excluding_vat, presence: true

  def update_subscription_on_rolling_update(prev_record,params)
    if prev_record.rolling_subscription != params[:rolling_subscription] || (params[:rolling_subscription] != "on" && prev_record.subscription_months != params[:subscription_months]&.to_i )
      UpdateRollingForAllSellersSubscriptionWorker.perform_async(self.id,params[:rolling_subscription],params[:subscription_months])
    end
  end

  def update_rolling_subscription_on_plan(params)
    UpdateRollingForAllSellersSubscriptionWorker.perform_async(self.id,params[:rolling_subscription],params[:subscription_months])
  end


  
end
