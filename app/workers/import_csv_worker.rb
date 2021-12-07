class ImportCsvWorker
  include Sidekiq::Worker

  def perform(csv_import_id,product_status)
    csv_import = CsvImport.where(id: csv_import_id, status: :uploaded).first
    return if csv_import.blank?
    importer = Products::Importer.call({csv_import: csv_import, product_status: product_status})
    if importer.status
      AdminMailer.with(to: csv_import.importer.email).send_csv_import_success_email.deliver_now
    else
      AdminMailer.with(to: csv_import.importer.email, errors: importer.errors.uniq.join('<br>')).send_csv_import_failed_email(importer.title_list).deliver_now
    end
  end
end
