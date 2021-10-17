class AdminMailer < ApplicationMailer

  def send_csv_import_success_email
    mail(to: params[:to], subject: 'Yavolo: CSV imported successfully')
  end

  def send_csv_import_failed_email
    @errors = params[:errors]
    mail(to: params[:to], subject: 'Yavolo: CSV import is failed')
  end

  def export_sellers_email(csv)
    attachments["#{Date.today}-sellers.csv"] = {mime_type: 'text/csv', content: csv}
    mail(to: "arhum.ali@phaedrasolutions.com", subject: 'Yavolo: CSV sellers data')
  end

  def import_sellers_email
    mail(to: params[:to], subject: 'Yavolo: Sellers Csv imported successfully')
  end
  

end
