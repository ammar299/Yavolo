class CreateFilterGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :filter_groups do |t|
      t.string :name
      t.integer :filter_group_type

      t.timestamps
    end
  end
end
