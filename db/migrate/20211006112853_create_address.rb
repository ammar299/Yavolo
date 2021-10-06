class CreateAddress < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :county
      t.string :state
      t.string :country
      t.string :postal_code
      t.string :phone_number
      t.integer :address_type

      t.timestamps
    end
  end
end
