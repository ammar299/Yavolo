class Buyers::ContactController < Buyers::BaseController
  skip_before_action :authenticate_buyer!

  def contact_us
  end

  def send_email_to_admin
    if params["g-recaptcha-response"].present?
      ContactUsMailer.with(email: params[:email_field], name: params[:name_field], subject: params[:subject_field], msg: params[:your_message_field]).send_contact_form_mail_to_admin.deliver_now
      ContactUsMailer.with(email: params[:email_field], name: params[:name_field], subject: params[:subject_field], msg: params[:your_message_field]).send_email_received_message_to_sender.deliver_now
      flash[:notice] = "Your response has been recorded"
      redirect_to contact_us_path
    else
      @errors = 'ReCaptcha is not filled.'
      respond_to do |format|  
        format.js { render 'buyers/contact/contact_us.js.erb'}
      end
    end
  end

end

