class AddRecoveryEmailToSellers < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :recovery_email, :string
  end
end
