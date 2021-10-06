class CreateDeliveryOptionShips < ActiveRecord::Migration[6.1]
  def change
    create_table :delivery_option_ships do |t|
      t.float :price
      t.references :delivery_option, foreign_key: true
      t.references :ship, foreign_key: true

      t.timestamps
    end
  end
end
