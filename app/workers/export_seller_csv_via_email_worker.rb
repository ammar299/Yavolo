class ExportSellerCsvViaEmailWorker
  include Sidekiq::Worker

  def perform(current_admin,csv)
    AdminMailer.export_sellers_email(current_admin,csv).deliver!
  end

end
