class SeoContent < ApplicationRecord
  include DuplicateRecord
  MAX_SEO_CONTENT_DESCRIPTION_LENGTH = 160
  belongs_to :product
  # validates :title, :url, :description, :keywords, presence: true
  validates :title, uniqueness: true, if: Proc.new { |seo| seo.title.present? && seo.product.check_for_seo_content_uniqueness }
  validates :description, uniqueness: true, if: Proc.new { |seo| seo.description.present? && seo.product.check_for_seo_content_uniqueness }

  def assign_meta_title_and_description(is_update_action: false)
    messages = ["Product was successfully #{is_update_action ? "updated" : "created" }."]
    return messages if self.title.present? && self.description.present?

    if SeoContent.where(title: product.seo_content.title).present? && self.title.blank?
        messages << "This product will have same meta title as a previous product because it will be system generated and it will be duplicating meta content"
    end

    if SeoContent.where(description: product.seo_content.description).present? && self.description.blank?
      if messages.size == 2
        messages[1] = "This product will have same meta content as a previous product because it will be system generated and it will be duplicating meta content"
      else
        messages[1] = "This product will have same meta description as a previous product because it will be system generated and it will be duplicating meta content"
      end
    end

    truncated_description = product.description.size > MAX_SEO_CONTENT_DESCRIPTION_LENGTH ? product.description[0...MAX_SEO_CONTENT_DESCRIPTION_LENGTH] : product.description
    self.title = product.title unless self.title.present?
    self.description = truncated_description unless self.description.present?
    self.save
    messages
  end
end
