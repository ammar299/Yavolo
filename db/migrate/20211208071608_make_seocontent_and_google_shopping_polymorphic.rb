class MakeSeocontentAndGoogleShoppingPolymorphic < ActiveRecord::Migration[6.1]
  def change
    rename_column :seo_contents, :product_id, :seo_content_able_id
    rename_column :google_shoppings, :product_id, :google_shopping_able_id

    add_column :seo_contents, :seo_content_able_type, :string
    add_column :google_shoppings, :google_shopping_able_type, :string
  end
end
