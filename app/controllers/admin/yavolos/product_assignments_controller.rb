class Admin::Yavolos::ProductAssignmentsController < Admin::BaseController

  def index
    @product_assignment_settings = ProductAssignmentSetting.first_or_initialize
  end

  def products_with_pagination
    case params[:current_tab]
    when "worthy_yas"
      @product_assignments = ProductAssignment.worthy_yas_and_worthy_ya_volos
    when "worthy_volos"
      @product_assignments = ProductAssignment.worthy_volos_and_worthy_ya_volos
    when "unworthy_yas"
      @product_assignments = ProductAssignment.unworthy_yas_and_unworthy_ya_volos
    when "unworthy_volos"
      @product_assignments = ProductAssignment.unworthy_volos_and_unworthy_ya_volos
    else
      @product_assignments = ProductAssignment.worthy_yas_and_worthy_ya_volos
    end
    @product_assignments = @product_assignments.includes(:product).page(params[:page]).per(15)
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
