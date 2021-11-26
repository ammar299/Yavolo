class AddColumnsToBankDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_details, :account_verification_status, :string
    add_column :bank_details, :requirements, :string
    add_column :bank_details, :individual_status, :string
  end
end
