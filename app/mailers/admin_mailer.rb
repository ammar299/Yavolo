class AdminMailer < ApplicationMailer

  def send_csv_import_success_email
    mail(to: params[:to], subject: 'Yavolo: CSV imported successfully')
  end

  def send_csv_import_failed_email
    @errors = params[:errors]
    mail(to: params[:to], subject: 'Yavolo: CSV import is failed')
  end

  def export_sellers_email(current_admin,csv)
    attachments["#{Date.today}-export-sellers.csv"] = {mime_type: 'text/csv', content: csv}
    mail(to: current_admin, subject: 'Yavolo: CSV sellers data')
  end

  def import_sellers_email
    mail(to: params[:to], subject: 'Yavolo: Sellers Csv imported successfully')
    puts "success email sent ******"
  end

  def import_sellers_failed_email
    @errors = params[:errors]
    mail(to: params[:to], subject: 'Yavolo: Sellers Csv import status')
    puts "failed email sent ******"
  end
  
  def send_account_creation_email
    @password = params[:password]
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been created.')
    puts "---- Email Sent ------"
  end
end
