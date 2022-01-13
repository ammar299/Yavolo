class ProductAssignment < ApplicationRecord
  belongs_to :product
  enum priority: {worthy_ya: 0, unworthy_ya: 1, worthy_volo: 2, unworthy_volo: 3, worthy_ya_volo: 4, unworthy_ya_volo: 5}, _prefix: true
  validates_presence_of :priority, :product, :total_revenue, :total_sales

  scope :all_worthy_products, -> { where(priority: ProductAssignment.worthy_values) }

  scope :worthy_yas_and_worthy_ya_volos, -> { where(priority: %w(worthy_ya worthy_ya_volo)) }
  scope :worthy_volos_and_worthy_ya_volos, -> { where(priority: %w(worthy_volo worthy_ya_volo)) }
  scope :unworthy_yas_and_unworthy_ya_volos, -> { where(priority: %w(unworthy_ya unworthy_ya_volo)) }
  scope :unworthy_volos_and_unworthy_ya_volos, -> { where(priority: %w(unworthy_volo unworthy_ya_volo)) }

  def self.worthy_values
    %w(worthy_ya worthy_volo worthy_ya_volo)
  end
end