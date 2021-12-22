class DeliveryOption < ApplicationRecord
  include PgSearch
  pg_search_scope :global_search, against: [:name]

  validate  :manage_unique_template

  has_many :delivery_option_ships, dependent: :destroy
  has_many :ships, through: :delivery_option_ships
  has_many :products
  belongs_to :delivery_optionable, polymorphic: true

  scope :admin_delivery_option, lambda { |class_name| where("delivery_optionable_type = ?", class_name) }

  def manage_unique_template
    delivery_option = DeliveryOption.find_by(handle: self.handle)
    return if self.id.present? && delivery_option.present? && self.id == delivery_option.id
    if delivery_option.present?
      delivery_type = delivery_option.delivery_optionable_type
      same_seller = if self.id.present? && delivery_type == 'Seller'
                      delivery_option.delivery_optionable_id != self.delivery_optionable_id
                    else
                      self.delivery_optionable_type == 'Seller' && delivery_type == 'Seller'
                    end

      if same_seller || (self.delivery_optionable_type == 'Admin' && delivery_type == 'Seller')
        self.errors[:base] << 'Template is already created by seller'
      elsif self.delivery_optionable_type == 'Seller' && delivery_type == 'Admin'
        self.errors[:base] << 'Template exists in Global Templates'
      else
        self.errors[:base] << 'Template already exists!'
      end
    end
  end
end
