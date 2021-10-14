class Carrier < ApplicationRecord
  validates :name, :api_key, :secret_key, presence: true
end
