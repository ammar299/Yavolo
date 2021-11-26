class AddBankDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_details, :account_holder_name, :string
    add_column :bank_details, :account_holder_type, :string
    add_column :bank_details, :customer_stripe_account_id, :string
  end
end
