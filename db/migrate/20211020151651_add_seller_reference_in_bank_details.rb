class AddSellerReferenceInBankDetails < ActiveRecord::Migration[6.1]
  def change
    add_reference :bank_details, :seller
  end
end
