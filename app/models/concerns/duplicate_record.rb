module DuplicateRecord
  extend ActiveSupport::Concern

  def duplicate
    self.id = nil
    self.product_id = nil
    self
  end
end
