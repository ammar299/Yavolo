require 'sidekiq-scheduler'

class AllProductsAutomaticBundlingWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(*args)
    job_id = self.jid
    begin
      AutomaticBundlingLastRun.create
      YavoloBundles::AllProductsAutomaticBundling.call
    rescue StandardError => e
      puts "Job with id #{job_id} failed"
      puts "AllProductsAutomaticBundlingWorker worker exception: #{e.message}"
    end
  end
end