class Admin::Yavolos::ProductAssignmentsController < Admin::BaseController

  def index
    @product_assignment_settings = ProductAssignmentSetting.first_or_initialize
  end

  def create_or_update
    @product_assignment_settings = ProductAssignmentSetting.first_or_initialize
    @product_assignment_settings.assign_attributes(product_assignment_settings_params)
    if @product_assignment_settings.save
      flash.now[:notice] = 'Settings updated successfully!'
    end
  end

  private

  def product_assignment_settings_params
    params.require(:product_assignment_setting).permit(:price, :items, :duration)
  end

end
