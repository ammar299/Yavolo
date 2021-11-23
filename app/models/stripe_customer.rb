class StripeCustomer < ApplicationRecord
  belongs_to :stripe_customerable, polymorphic: true
end