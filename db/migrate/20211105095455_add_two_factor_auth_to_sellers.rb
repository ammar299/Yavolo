class AddTwoFactorAuthToSellers < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :two_factor_auth, :boolean, default: false
  end
end
