class CreateCarriers < ActiveRecord::Migration[6.1]
  def change
    create_table :carriers do |t|
      t.string :name
      t.string :api_key
      t.string :secret_key

      t.timestamps
    end
  end
end
