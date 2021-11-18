class AddColumnsInPaymentMethod < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_payment_methods, :last_digits, :string
    add_column :seller_payment_methods, :card_holder_name, :string
    add_column :seller_payment_methods, :payment_terms, :string
  end
end
