class AddDefaultCardStatus < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_payment_methods, :default_status, :boolean
  end
end
