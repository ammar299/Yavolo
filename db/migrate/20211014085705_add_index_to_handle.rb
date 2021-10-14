class AddIndexToHandle < ActiveRecord::Migration[6.1]
  def change
    add_index :products, :handle, unique: true
  end
end
