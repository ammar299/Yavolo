class ContactUsMailer < ApplicationMailer

  def send_contact_form_mail_to_admin
    @name = params[:name]
    @email = params[:email]
    @subject = params[:subject]
    @msg = params[:msg]
    Admin.all.map(&:email).each do |ad|
      mail(to: ad, subject: @subject, email: @email, message: @msg)
    end
  end

  def send_email_received_message_to_sender
    @name = params[:name]
    @email = params[:email]
    @subject = params[:subject]
    @msg = params[:msg]
    mail(to: @email, subject: @subject, email: @email, message: @msg)
  end
end
