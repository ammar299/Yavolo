class AddPreviousStatusToYavoloBundle < ActiveRecord::Migration[6.1]
  def change
    add_column :yavolo_bundles, :previous_status, :integer
  end
end
