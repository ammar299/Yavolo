class ChangeColumnNameToBankDetail < ActiveRecord::Migration[6.1]
  def change
    rename_column :bank_details, :individual_status, :available_payout_methods
  end
end
