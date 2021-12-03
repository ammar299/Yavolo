class ExportCsvWorker
  include Sidekiq::Worker

  def perform(owner_id,owner_type,product_ids)
      return false if owner_id.blank?
      owner = owner_type.constantize.where(id: owner_id).first
      return false if owner.blank?
      products = Product.where(id: [product_ids])
      exporter = Products::Exporter.call({ owner: products })
      if exporter.status
        CsvMailer.with( to: owner.email, csv: exporter.csv_file ).send_exported_csv_file_email.deliver_now
      end
  end
end
