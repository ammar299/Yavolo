class ExportOrdersCsvWorker
  include Sidekiq::Worker

  def perform(owner_id,owner_type,all_orders)
    return false if owner_id.blank?
    owner = owner_type.constantize.where(id: owner_id).first
    return false if owner.blank?
    orders = Order.where(id: [all_orders])
    exporter = Orders::Exporter.call({ owner: orders })
    if exporter.status
      CsvMailer.with( to: owner.email, csv: exporter.csv_file ).send_exported_csv_file_email.deliver_now
    end
  end
end