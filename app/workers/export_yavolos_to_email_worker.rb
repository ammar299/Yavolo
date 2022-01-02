class ExportYavolosToEmailWorker
  include Sidekiq::Worker

  def perform(yavolos)
    csv =  YavoloBundles::Exporter.call(yavolos).csv_file
    AdminMailer.send_yavolos_email(csv).deliver! if csv.present?
  end
end
