module SharedProductMethods
  extend ActiveSupport::Concern

  def bulk_products_update
    valid_actions =['activate','deactivate','yavolo_enabled','yavolo_disabled','delete','update_price','update_stock','update_discount']
    action = bulk_action_params[:action]
    product_ids = bulk_action_params[:product_ids]
    value = bulk_action_params[:value]
    value = value.to_d
    if valid_actions.include?(action)
      update_hash = {}
      update_hash.merge!(status: :active) if action =='activate'
      update_hash.merge!(status: :inactive) if action =='deactivate'
      update_hash.merge!(yavolo_enabled: true) if action =='yavolo_enabled'
      update_hash.merge!(yavolo_enabled: false) if action =='yavolo_disabled'
      update_hash.merge!(price: value) if action =='update_price'
      update_hash.merge!(stock: value) if action =='update_stock'
      update_hash.merge!(discount: value) if action =='update_discount'

      result = Product.where(id: product_ids).where(owner_conditions).update(update_hash) if action.present? && update_hash.present?
      result = Product.where(id: product_ids).where(owner_conditions).destroy_all if action=='delete'
      result_errors = result.map{|p| p.errors.full_messages}.flatten
      if result_errors.present?
        render json: { errors: result_errors }, status: :unprocessable_entity
      else
        render json: { notice: 'updated', update_ids: result.map(&:id), value: value, action: action }, status: :ok
      end
    else
      render json: { errors: ['invalid action or params are missing'] }, status: :unprocessable_entity
    end
  end

  def enable_yavolo
    if params[:product][:ids].present?
      if current_user.class.name == 'Seller'
        @products = Product.where(id: params[:product][:ids], yavolo_enabled: false, owner_id: current_user.id, owner_type: current_user.class.name).update(yavolo_enabled: true)
      else
        @products = Product.where(id: params[:product][:ids], yavolo_enabled: false).update(yavolo_enabled: true)
      end
    end
  end

  def disable_yavolo
    if params[:product][:ids].present?
      if current_user.class.name == 'Seller'
        @products = Product.where(id: params[:product][:ids], yavolo_enabled: true, owner_id: current_user.id, owner_type: current_user.class.name).update(yavolo_enabled: false)
      else
        @products = Product.where(id: params[:product][:ids], yavolo_enabled: true).update(yavolo_enabled: false)
      end
    end
  end

  private
    def bulk_action_params
      @bulk_params ||= params.require(:product).permit(:action,:value,product_ids:[])
    end

    def owner_conditions
      if current_user.class.name == 'Seller'
        {owner_id: current_user.id, owner_type: current_user.class.name}
      else
        {}
      end
    end

end
