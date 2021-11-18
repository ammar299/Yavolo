Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key => ENV['STRIPE_PRIVATE_KEY']

}

Stripe.api_key = ENV['STRIPE_PRIVATE_KEY']