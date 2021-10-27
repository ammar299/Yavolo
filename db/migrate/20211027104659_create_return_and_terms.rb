class CreateReturnAndTerms < ActiveRecord::Migration[6.1]
  def change
    create_table :return_and_terms do |t|
      t.integer :duration
      t.boolean :email_format, default: false
      t.boolean :authorisation_and_prepaid, default: false
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
