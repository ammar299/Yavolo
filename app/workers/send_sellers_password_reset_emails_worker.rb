class SendSellersPasswordResetEmailsWorker
  include Sidekiq::Worker

  def perform(seller_ids)
    seller_ids.each do |seller_id|
      seller = Seller.find(seller_id)
      raw, hashed = Devise.token_generator.generate(Seller, :reset_password_token)
      seller.reset_password_token = hashed
      seller.reset_password_sent_at = Time.now.utc
      if seller.save
        Devise::Mailer.reset_password_instructions(seller, raw).deliver_now
      end
    end

  rescue StandardError => e
    puts e.message
    puts "Something went wrong while sending emails in worker SendSellersPasswordResetEmailsWorker"
  end

end
