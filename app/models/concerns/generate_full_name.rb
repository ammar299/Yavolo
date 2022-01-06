module GenerateFullName
  extend ActiveSupport::Concern

  included do
    after_save :update_full_name
  end

  def update_full_name
    update_columns(full_name: "#{self.first_name} #{self.last_name}")
  end
end
