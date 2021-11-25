class BankDetail < ApplicationRecord
  belongs_to :seller
  validates :account_number, confirmation: true

  def get_refresh_onboarding_link
    link = Stripe::AccountLink.create(
      account: customer_stripe_account_id,
      refresh_url: "#{ENV['HOST_DOMAIN']}/sellers/check_onboarding_status",
      return_url: "#{ENV['HOST_DOMAIN']}/sellers/check_onboarding_status",
      type: 'account_onboarding',
      collect: 'eventually_due',
    )
    self.update(onboarding_link: link.url) if link == true
    return link.url
  end

  def check_account_status
    Stripe::Account.retrieve(customer_stripe_account_id)
  end

  def remove_bank_account
    account = Stripe::Account.delete(customer_stripe_account_id)
    remove_account_from_db if account.deleted == true
  end

  def remove_account_from_db
    self.update(remove_params)
  end

  def remove_params
    {
      currency: nil,
      country: nil,
      sort_code: nil,
      account_number: nil,
      account_holder_name: nil,
      account_holder_type: nil,
      customer_stripe_account_id: nil,
      account_verification_status: nil,
      requirements: nil,
      available_payout_methods: nil,
      bank_name: nil,
      last4: nil,
      fingerprint: nil,
      onboarding_link: nil,
      stripe_account_type: nil
    }
  end

end
