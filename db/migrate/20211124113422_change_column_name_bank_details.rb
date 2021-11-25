class ChangeColumnNameBankDetails < ActiveRecord::Migration[6.1]
  def change
    rename_column :bank_details, :external_account_disabled_reason, :fingerprint
  end
end
