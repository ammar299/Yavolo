class ChangeDestroyStripeBankDetails < ActiveRecord::Migration[6.1]
  def change
    drop_table :stripe_bank_details
  end
end
