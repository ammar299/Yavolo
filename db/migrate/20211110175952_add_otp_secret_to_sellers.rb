class AddOtpSecretToSellers < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :otp_secret, :string
    add_column :sellers, :last_otp_at, :integer
  end
end
