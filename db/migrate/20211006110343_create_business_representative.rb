class CreateBusinessRepresentative < ActiveRecord::Migration[6.1]
  def change
    create_table :business_representatives do |t|
      t.string :email
      t.string :job_title
      t.date :date_of_birth
      t.string :contact_number

      t.timestamps
    end
    add_index :business_representatives, :email, unique: true
  end
end
