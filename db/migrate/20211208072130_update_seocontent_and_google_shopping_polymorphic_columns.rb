class UpdateSeocontentAndGoogleShoppingPolymorphicColumns < ActiveRecord::Migration[6.1]
  def up
    SeoContent.update_all(seo_content_able_type: "Product")
    GoogleShopping.update_all(google_shopping_able_type: "Product")
  end
end
