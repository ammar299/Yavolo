class AddExpMonthExpYearInBuyerPaymentMethod < ActiveRecord::Migration[6.1]
  def change
    add_column :buyer_payment_methods, :exp_month, :integer
    add_column :buyer_payment_methods, :exp_year, :integer
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
