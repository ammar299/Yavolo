class CreateSellerApis < ActiveRecord::Migration[6.1]
  def change
    create_table :seller_apis do |t|
      t.string :name
      t.string :api_token
      t.integer :status
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
