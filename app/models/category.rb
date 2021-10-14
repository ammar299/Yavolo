class Category < ApplicationRecord
  has_ancestry
  validates :category_name, uniqueness: true,presence: true

  has_many :category_filter_groups, dependent: :destroy
  has_many :filter_groups, through: :category_filter_groups

  validates :category_id, uniqueness: true,presence: true

  has_one :picture, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for   :picture

  before_save :assign_unique_category_id_string
  before_save :assign_url

  def assign_unique_category_id_string
    return if self.category_id_string.present?
    loop do
      self.category_id_string = "PS-"+SecureRandom.send('choose',[*'0'..'9'], 6).scan(/.{1,2}/).join("-")
      break unless self.class.exists?(category_id_string: category_id_string)
    end
  end

  def assign_url
    return if self.url.present?
    self.url = self.category_name.parameterize if self.category_name.present?
  end


end
