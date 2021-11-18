class StripeBankDetail < ApplicationRecord
  enum bank_account_type: [:basic_banking_account,:current_account,:savings_account,:foreign_currency_account,:fixed_deposit_account]
  belongs_to :seller

  validates :number, confirmation: true
  validates :number_confirmation, presence: true
  validate :bank_account_details
  
  def bank_account_details
    errors.add(:number, "Account Number can't be blank") if number.blank?
    if number_confirmation.blank?
        errors.delete(:number_confirmation)
        errors.add(:number_confirmation, "Confirm Account Number can't be blank")
    end
    
    if number != number_confirmation
        errors.delete(:number_confirmation)
        errors.add(:number_confirmation, "Confirm Account Number doesn't match")
    end

    errors.add(:routing_number, "Routing Number can't be blank") if routing_number.blank?
    errors.add(:bank_name, "Bank Name can't be blank") if bank_name.blank?
    errors.add(:id_number, "Social Security Number can't be blank") if id_number.blank?
  end
end