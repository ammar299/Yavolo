class AddTermAndConditionsInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :terms_and_conditions, :boolean, default: false
    add_column :sellers, :recieve_deals_via_email, :boolean, default: false
  end
end
