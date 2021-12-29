class CreateSubscriptionLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_logs do |t|
      t.string :error
      t.string :type
      t.references :seller, foreign_key: true
      t.timestamps
    end
  end
end
