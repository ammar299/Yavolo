class ExportCsvWorker
  include Sidekiq::Worker

  def perform(owner_id,owner_type)
      return false if owner_id.blank?
      owner = owner_type.constantize.where(id: owner_id).first
      return false if owner.blank?
      exporter = Products::Exporter.call({ owner: owner })
      if exporter.status
        CsvMailer.with( to: owner.email, csv: exporter.csv_file ).send_exported_csv_file_email.deliver_now
      end
  end
end
