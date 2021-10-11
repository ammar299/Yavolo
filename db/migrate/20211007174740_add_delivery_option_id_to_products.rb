class AddDeliveryOptionIdToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :delivery_option, index: true
  end
end
