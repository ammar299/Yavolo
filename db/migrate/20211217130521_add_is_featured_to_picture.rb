class AddIsFeaturedToPicture < ActiveRecord::Migration[6.1]
  def change
    add_column :pictures, :is_featured, :boolean, default: false
  end
end
