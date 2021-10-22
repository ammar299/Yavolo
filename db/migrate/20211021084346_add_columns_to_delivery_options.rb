class AddColumnsToDeliveryOptions < ActiveRecord::Migration[6.1]
  def change
    add_reference :delivery_options, :delivery_optionable, polymorphic: true, index: true
  end
end
