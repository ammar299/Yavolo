class AssociateBuyerPaymentMethodWithOrder < ActiveRecord::Migration[6.1]
  def change
    add_reference :orders, :buyer_payment_method
  end
end
