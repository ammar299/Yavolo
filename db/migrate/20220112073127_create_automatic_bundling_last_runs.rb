class CreateAutomaticBundlingLastRuns < ActiveRecord::Migration[6.1]
  def change
    create_table :automatic_bundling_last_runs do |t|

      t.timestamps
    end
  end
end
