class AddMultiStepSignUpFieldInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :multistep_sign_up, :boolean, default: true
  end
end
