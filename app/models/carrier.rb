class Carrier < ApplicationRecord
  validate :matching_api_and_secret_keys
  validates :name, :api_key, :secret_key, presence: true

  def matching_api_and_secret_keys
    self.errors.add(:secret_key, message: "can't be the same as Api key") if api_key == secret_key
  end
end
