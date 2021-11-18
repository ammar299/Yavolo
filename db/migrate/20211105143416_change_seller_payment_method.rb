class ChangeSellerPaymentMethod < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_payment_methods, :card_id, :string
  end
end
