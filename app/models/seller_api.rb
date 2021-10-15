class SellerApi < ApplicationRecord
  belongs_to :seller
  enum status: { enable: 0, disable: 1 }
end
