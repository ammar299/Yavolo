class CreateBillingListingStripe < ActiveRecord::Migration[6.1]
  def change
    create_table :billing_listing_stripes do |t|
      t.string :invoice_id
      t.float :total
      t.string :description
      t.datetime :date_generated
      t.datetime :due_date
      t.string :status
      t.timestamps
    end
  end
end
