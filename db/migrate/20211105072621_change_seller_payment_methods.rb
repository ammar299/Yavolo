class ChangeSellerPaymentMethods < ActiveRecord::Migration[6.1]
  def change
    rename_column :seller_payment_methods, :type, :payment_method_type
  end
end
