class Payment < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.boolean :paid, :default => false
      t.string :token
      t.integer :price
      t.timestamps
    end
  end
end
