class CreateOrderDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :order_details do |t|
      t.string :name
      t.string :email
      t.string :contact_number

      t.timestamps
    end
  end
end
