class CreateAssignedCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :assigned_categories do |t|
      t.references :product, index: true
      t.references :category, index: true
      t.timestamps
    end
  end
end
