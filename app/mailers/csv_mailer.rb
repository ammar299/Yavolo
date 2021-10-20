class CsvMailer < ApplicationMailer
  def send_exported_csv_file_email
    attachments["products_#{Time.zone.now.to_i}.csv"] = {mime_type: 'text/csv', content: params[:csv]}
    mail(to: params[:to], subject: 'Yavolo: CSV exported successfully')
  end
end
