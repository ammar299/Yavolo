class AdminMailer < ApplicationMailer

  # def send_csv_import_email(errors, list, existing_product_list)
  #   @errors = errors.join('<br>')
  #   @list = list.join('<br>')
  #   @existing_product_list = existing_product_list.join('<br>')
  #   mail(to: params[:to], subject: 'Yavolo: CSV imported successfully')
  # end

  def send_csv_import_success_email
    # TODO: 'remove khawar work after testing' remove exisiting_product_list from seo_content
    # @existing_product_list = existing_product_list.join('<br>')
    mail(to: params[:to], subject: 'Yavolo: CSV imported successfully')
  end

  def send_csv_import_failed_email(list)
    @errors = params[:errors]
    @list = list.join('<br>')
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
    @token = params[:token]
    @seller = params[:seller]
    mail = mail(to: params[:to], subject: 'Yavolo: Your seller account has been created.')
    puts "---- Email Sent ------"
    return true
  end

  def send_account_creation_email_admin_seller
    @seller = Seller.find_by_email(params[:to])
    @token = params[:token]
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been created.')
    puts "---- Email Sent for send_account_creation_email_admin_seller ------"
  end

end
