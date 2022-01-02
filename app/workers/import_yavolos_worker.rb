class ImportYavolosWorker
  include Sidekiq::Worker

  def perform(csv_import_id)
      csv_import = CsvImport.where(id: csv_import_id, status: :uploaded).first
      return if csv_import.blank?
      importer = YavoloBundles::Importer.call({csv_import: csv_import})
      if importer.status
        AdminMailer.with(to: csv_import.importer.email).import_yavolos_email.deliver_now
      else
        AdminMailer.with(to: csv_import.importer.email, errors: importer.errors).import_yavolos_failed_email(importer.title_list).deliver_now
      end
  end

end
