class AddForeignKeyToBillingListingTable < ActiveRecord::Migration[6.1]
  def change
    add_reference :billing_listing_stripes, :seller, foreign_key: true
  end
end
