class SellerApi < ApplicationRecord
  belongs_to :seller
  validates :developer_id, uniqueness: { message: "developer Id must be unique" }
  validates :app_name, uniqueness: { message: "app name must be unique" }
  enum status: { enable: 0, disable: 1 }
  before_create :create_api_token
  # before_update :renew_api_token


  def create_api_token
    self.api_token = SecureRandom.hex(30)
    self.developer_id = SecureRandom.hex(7)
    self.expiry_date = Date.today + 6.month
    self.status = 'enable'
  end
end
