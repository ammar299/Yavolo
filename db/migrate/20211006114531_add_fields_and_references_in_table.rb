class AddFieldsAndReferencesInTable < ActiveRecord::Migration[6.1]
  def change
    #Add References to Tables
    add_reference :business_representatives, :seller
    add_reference :addresses, :seller
    add_reference :company_details, :seller

    #Add Fields in Company Details add_column
    add_column :company_details, :website_url, :string, default: ""
    add_column :company_details, :amazon_url, :string, default: ""
    add_column :company_details, :ebay_url, :string, default: ""
  end
end
