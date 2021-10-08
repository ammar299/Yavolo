class CreateDeliveryOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :delivery_options do |t|
      t.string :name
      t.integer :processing_time
      t.integer :delivery_time

      t.timestamps
    end
  end
end
