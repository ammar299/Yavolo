class SeoContent < ApplicationRecord
  include DuplicateRecord
  MAX_SEO_CONTENT_DESCRIPTION_LENGTH = 160
  belongs_to :seo_content_able, polymorphic: true
  # validates :title, :url, :description, :keywords, presence: true
  validates :title, uniqueness: true, if: Proc.new { |seo| seo.title.present? && seo.seo_content_able.check_for_seo_content_uniqueness }
  validates :description, uniqueness: true, if: Proc.new { |seo| seo.description.present? && seo.seo_content_able.check_for_seo_content_uniqueness }

  def assign_meta_title_and_description(is_update_action: false)
    messages = ["Product was successfully #{is_update_action ? "updated" : "created" }."]
    return messages if self.title.present? && self.description.present?

    if SeoContent.where(title: seo_content_able.title).present? && self.title.blank?
        messages << "This product will have same meta title as a previous product because it will be system generated and it will be duplicating meta content"
    end

    if SeoContent.where(description: seo_content_able.description).present? && self.description.blank?
      if messages.size == 2
        messages[1] = "This product will have same meta content as a previous product because it will be system generated and it will be duplicating meta content"
      else
        messages[1] = "This product will have same meta description as a previous product because it will be system generated and it will be duplicating meta content"
      end
    end

    truncated_description = seo_content_able.description.size > MAX_SEO_CONTENT_DESCRIPTION_LENGTH ? seo_content_able.description[0...MAX_SEO_CONTENT_DESCRIPTION_LENGTH] : seo_content_able.description
    self.title = seo_content_able.title unless self.title.present?
    self.description = truncated_description unless self.description.present?
    self.save
    messages
  end
end
