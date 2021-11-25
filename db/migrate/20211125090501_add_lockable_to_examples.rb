class AddLockableToExamples < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :failed_attempts, :integer, default: 0
    add_column :sellers, :unlock_token, :string
    add_column :sellers, :locked_at, :datetime
  end
end
