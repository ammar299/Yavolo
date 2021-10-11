class CreateCompanyDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :company_details do |t|
      t.string :name
      t.string :vat_number
      t.string :country
      t.string :legal_business_name
      t.string :companies_house_registration_number
      t.string :business_industry
      t.string :business_phone

      t.timestamps
    end
  end
end
