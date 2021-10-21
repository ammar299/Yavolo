class ChangeDefaultColumnValueInProducts < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:products, :filter_in_category_ids, nil)
  end
end
