class RenameColumnNAmeInBankDetails < ActiveRecord::Migration[6.1]
  def change
    rename_column :bank_details, :external_account_pending_verification, :onboarding_link
  end
end
