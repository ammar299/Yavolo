class ExportYavolosToEmailWorker
  include Sidekiq::Worker

  def perform(yavolos)
    csv = YavoloBundle.new.export_yavolos(yavolos)
    AdminMailer.send_yavolos_email(csv).deliver! if csv.present?
  end
end
