class ReturnAndTerm < ApplicationRecord
  enum duration: { '30_days_of_dispatch': 0, '40_days_of_dispatch': 1, '50_days_of_dispatch': 2, '60_days_of_dispatch': 3 }

  belongs_to :seller
end
