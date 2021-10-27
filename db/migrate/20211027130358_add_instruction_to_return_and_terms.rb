class AddInstructionToReturnAndTerms < ActiveRecord::Migration[6.1]
  def change
    add_column :return_and_terms, :instructions, :string
  end
end
