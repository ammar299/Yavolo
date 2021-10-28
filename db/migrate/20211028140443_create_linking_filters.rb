class CreateLinkingFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :linking_filters do |t|
      t.integer :filter_in_category_id
      t.integer :category_id

      t.timestamps
    end
  end
end
