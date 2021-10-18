class CreateMetaContents < ActiveRecord::Migration[6.1]
  def change
    create_table :meta_contents do |t|
      t.string :title
      t.text :keywords
      t.text :description
      t.string :url
      t.references :meta_able, polymorphic: true, index: true

      t.timestamps
    end
  end
end
