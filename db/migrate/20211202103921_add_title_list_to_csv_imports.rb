class AddTitleListToCsvImports < ActiveRecord::Migration[6.1]
  def change
    add_column :csv_imports, :title_list, :text
    add_column :csv_imports, :existing_product_list, :text
  end
end
