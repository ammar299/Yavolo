class ImportSellersWorker
  include Sidekiq::Worker

  def perform(csv_import_id)
      csv_import = CsvImport.where(id: csv_import_id, status: :uploaded).first
      return if csv_import.blank?
      importer = Sellers::ImportSeller.call({csv_import: csv_import})
      if importer.status
        AdminMailer.with(to: csv_import.importer.email).import_sellers_email.deliver_now
      else
        AdminMailer.with(to: csv_import.importer.email, errors: importer.errors.join('<br>')).import_sellers_failed_email.deliver_now
      end
  end

end
