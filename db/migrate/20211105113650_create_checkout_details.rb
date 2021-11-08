class CreateCheckoutDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :checkout_details do |t|
      t.string :name
      t.string :contact_number
      t.string :email
      t.string :company_name

      t.timestamps
    end
  end
end
