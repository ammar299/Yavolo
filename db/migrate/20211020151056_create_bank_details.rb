class CreateBankDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :bank_details do |t|
      t.string :currency
      t.string :country
      t.string :sort_code
      t.string :account_number

      t.timestamps
    end
  end
end
