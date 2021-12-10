class AddNewColumnsToYavoloBundle < ActiveRecord::Migration[6.1]
  def change
    add_column :yavolo_bundles, :stock_limit, :integer
    add_column :yavolo_bundles, :max_stock_limit, :integer
    add_column :yavolo_bundles, :regular_total, :decimal,precision: 8, scale: 2
    add_column :yavolo_bundles, :yavolo_total, :decimal,precision: 8, scale: 2
  end
end
