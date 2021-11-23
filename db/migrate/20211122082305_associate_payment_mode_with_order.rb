class AssociatePaymentModeWithOrder < ActiveRecord::Migration[6.1]
  def change
    remove_reference :payment_modes, :buyer
    add_reference :payment_modes, :order
  end
end
