# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
# ActionMailer::Base.smtp_settings = {
#   address: 'smtp-relay.sendinblue.com',
#   port: 587, 
#   domain: 'sendinblue.com',
#   authentication: 'login', 
#   enable_starttls_auto: true, 
#   user_name: 'talha.waseem@phaedrasolutions.com',
#   password: 't13pSOXn0WQcVmrT'
# }
ActionMailer::Base.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'gmail.com',
  user_name:            "yavolotalha@gmail.com",
  password:             "talhayavolo123",
  authentication:       'plain',
  enable_starttls_auto: true,
  openssl_verify_mode: 'none' 
}

# yavolotalha@gmail.com
  # talhayavolo123