class CreateSeoContents < ActiveRecord::Migration[6.1]
  def change
    create_table :seo_contents do |t|
      t.string :title
      t.text :url
      t.text :description
      t.text :keywords
      t.references :product, index: true
      t.timestamps
    end
  end
end
