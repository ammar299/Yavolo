class CancelSubscriptionsOnDestroySellerWorker
  include Sidekiq::Worker

  def perform(*args)
    begin
      sub = Stripe::Subscription.delete(
        args[0],
      )
    rescue => e
      puts "Cancel subscription on seller delete worker exception: #{e.message}"
    end
  end
end