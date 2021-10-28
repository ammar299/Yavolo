class RemoveUniqueIndexFromBusinessRepresentative < ActiveRecord::Migration[6.1]
  def change
    remove_index :business_representatives, :email, unique: true
    add_index :business_representatives, :email, unique: false
  end
end
