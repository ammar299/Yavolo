class RemoveExistingProductListToCsvImports < ActiveRecord::Migration[6.1]
  def up
    remove_column :csv_imports, :existing_product_list, :text
  end

  def down
    add_column :csv_imports, :existing_product_list, :text
  end
end
