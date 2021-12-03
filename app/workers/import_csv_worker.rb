class ImportCsvWorker
  include Sidekiq::Worker

  def perform(csv_import_id)
    csv_import = CsvImport.where(id: csv_import_id, status: :uploaded).first
    return if csv_import.blank?
    importer = Products::Importer.call({csv_import: csv_import})
    if importer.status
      AdminMailer.with(to: csv_import.importer.email).send_csv_import_success_email.deliver_now
    else
      AdminMailer.with(to: csv_import.importer.email, errors: importer.errors.uniq.join('<br>')).send_csv_import_failed_email(importer.title_list).deliver_now
    end
    # TODO: 'remove khawar work after testing' csv upload email work
    # AdminMailer.with(to: csv_import.importer.email).send_csv_import_email(importer.errors.uniq, importer.title_list, importer.existing_product_list).deliver_now
  end
end
