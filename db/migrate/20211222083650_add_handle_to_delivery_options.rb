class AddHandleToDeliveryOptions < ActiveRecord::Migration[6.1]
  def change
    add_column :delivery_options, :handle, :string
  end
end
