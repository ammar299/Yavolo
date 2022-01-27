class AddHolidayReasonInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :holiday_reason ,:text
  end
end
