class AddDeliveryAndProcessTimeToDeliveryOptionShips < ActiveRecord::Migration[6.1]
  def up
    remove_column :delivery_options, :processing_time, :integer
    remove_column :delivery_options, :delivery_time, :integer
    add_column :delivery_option_ships, :processing_time, :integer
    add_column :delivery_option_ships, :delivery_time, :integer
  end

  def down
    add_column :delivery_options, :processing_time, :integer
    add_column :delivery_options, :delivery_time, :integer
    remove_column :delivery_option_ships, :processing_time, :integer
    remove_column :delivery_option_ships, :delivery_time, :integer
  end
end
