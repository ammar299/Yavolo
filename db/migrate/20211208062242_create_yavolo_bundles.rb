class CreateYavoloBundles < ActiveRecord::Migration[6.1]
  def change
    create_table :yavolo_bundles do |t|
      t.string "title"
      t.string "handle"
      t.text "description"
      t.references :category, index: true
      t.integer "status"
      t.string "yan"
      t.integer "quantity"
      t.decimal "price", precision: 8, scale: 2

      t.index ["status"], name: "index_yavolo_bundles_on_status"
      t.index ["title"], name: "index_yavolo_bundles_on_title"
      t.index ["yan"], name: "index_yavolo_bundles_on_yan"

      t.timestamps
    end
  end
end
