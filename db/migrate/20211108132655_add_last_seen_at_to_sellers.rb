class AddLastSeenAtToSellers < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :last_seen_at, :datetime
  end
end
