class BankDetail < ApplicationRecord
  validates :account_number, confirmation: true
end
