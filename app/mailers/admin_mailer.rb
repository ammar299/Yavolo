class AdminMailer < ApplicationMailer

  def send_csv_import_success_email
    mail(to: params[:to], subject: 'Yavolo: CSV imported successfully')
  end

  def send_csv_import_failed_email
    @errors = params[:errors]
    mail(to: params[:to], subject: 'Yavolo: CSV import is failed')
  end
end
