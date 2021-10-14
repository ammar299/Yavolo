class CreateCsvImports < ActiveRecord::Migration[6.1]
  def change
    create_table :csv_imports do |t|
      t.string  :file
      t.bigint  :importer_id
      t.string  :importer_type
      t.integer :status
      t.text :import_errors
      t.timestamps
    end
    add_index :csv_imports, [:importer_type, :importer_id]
  end
end
