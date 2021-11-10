class AddTimeoutToSellers < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :timeout, :integer
  end
end
