class AddFieldsToBankDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_details, :bank_name, :string
    add_column :bank_details, :last4, :string
    add_column :bank_details, :external_account_disabled_reason, :string
    add_column :bank_details, :external_account_pending_verification, :string
    add_column :bank_details, :stripe_account_type, :string
  end
end
