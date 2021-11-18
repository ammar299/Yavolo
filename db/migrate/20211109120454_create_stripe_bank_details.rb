class CreateStripeBankDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :stripe_bank_details do |t|
      t.integer "bank_account_type"
      t.string "title"
      t.string "routing_number"
      t.string "number"
      t.string "bank_name"
      t.timestamps
    end
  end
end
