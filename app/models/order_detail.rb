class OrderDetail < ApplicationRecord
  include GenerateFullName

  belongs_to :order

end
