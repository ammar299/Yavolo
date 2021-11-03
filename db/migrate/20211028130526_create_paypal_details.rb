class CreatePaypalDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :paypal_details do |t|
      t.boolean :integration_status
      t.string :seller_merchant_id_in_paypal
      t.string :seller_client_id
      t.string :seller_tracking_id
      t.references :seller, null: false, foreign_key: true
      t.timestamps
    end
  end
end
