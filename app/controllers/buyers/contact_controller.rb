class Buyers::ContactController < Buyers::BaseController

  def contact_us
  end

  def send_email_to_admin
    if params["g-recaptcha-response"].present?
      ContactUsMailer.with(email: params[:email_field], name: params[:name_field], subject: params[:subject_field], msg: params[:your_message_field]).send_contact_form_mail_to_admin.deliver_now
      ContactUsMailer.with(email: params[:email_field], name: params[:name_field], subject: params[:subject_field], msg: params[:your_message_field]).send_email_received_message_to_sender.deliver_now
      flash[:notice] = "Your response has been recorded"
      redirect_to contact_us_path
    else
      redirect_to contact_us_path
      flash[:notice] = "You need to select ReCaptcha"
    end
  end

end

