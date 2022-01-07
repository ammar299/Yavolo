class AddFirstAndLastNameToCompanyDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :company_details, :first_name, :string
    add_column :company_details, :last_name, :string
  end
end
