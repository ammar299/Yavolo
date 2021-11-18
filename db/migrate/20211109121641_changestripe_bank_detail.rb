class ChangestripeBankDetail < ActiveRecord::Migration[6.1]
  def change
    add_reference :stripe_bank_details, :seller, foreign_key: true
  end
end
