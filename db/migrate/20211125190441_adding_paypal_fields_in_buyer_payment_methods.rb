class AddingPaypalFieldsInBuyerPaymentMethods < ActiveRecord::Migration[6.1]
  def change
    rename_column :buyer_payment_methods, :stripe_token, :token
    # Ex:- rename_column("admin_users", "pasword","hashed_pasword")
    add_column :buyer_payment_methods, :payment_method_type, :integer
    # Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
