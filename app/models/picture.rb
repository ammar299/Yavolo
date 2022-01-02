class Picture < ApplicationRecord
    belongs_to :imageable, polymorphic: true, optional: true
    mount_uploader :name, PictureUploader
		attr_accessor :file_metadata

    validates :name, presence: { message: 'Product picture not attached'}

    validate :validate_attachments

		scope :featured, -> { where(is_featured: true) }

    private
		def validate_attachments
			file_content_and_size_validation(:name)
    end

    def file_content_and_size_validation(field)
			custom_errors = ["#{field.to_s.titleize}:"]
			allowed_extentions = ['jpg','jpeg','png','gif', 'webp']
			msg = "Only files with the following extensions are allowed: JPG, JPEG,GIF & PNG and file must be less than 10MB."
			if send(field).present?
					if send(field).size > 10.megabytes
						custom_errors.insert(1,msg)
					end
					valid_extention = []
					if file_metadata.present? && file_metadata[field.to_s].present?
						valid_extention = allowed_extentions.select{|ext| file_metadata[field.to_s]['ext'].include?(ext) }
						custom_errors.insert(1,msg) if valid_extention.blank?
					end
			else
					if file_metadata.present? && file_metadata[field.to_s].present? && file_metadata[field.to_s]['file_exist'] == false
						errors.delete(field)
						custom_errors.insert(1,msg)
					end
			end
			if custom_errors.present?
					errors.add(field, custom_errors.join(" ")) if custom_errors.length > 1
			end
    end
end
