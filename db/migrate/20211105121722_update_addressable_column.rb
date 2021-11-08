class UpdateAddressableColumn < ActiveRecord::Migration[6.1]
  def change
    Address.update_all("addressable_id=seller_id,addressable_type='Seller'")

    remove_column :addresses, :seller_id
  end
end
