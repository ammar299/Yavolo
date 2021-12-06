class AddReviewedLoginScreenInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :reviewed_login_screen, :boolean, default: false
  end
end
