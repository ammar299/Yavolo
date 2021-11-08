class Buyers::CartController < ApplicationController

  def cart
    @cart = session[:_current_user_cart] ||= []
    product_ids = @cart.map{ |item| item[:product_id] }
    @products = Product.find(product_ids)
  end

  def store_front
  end

  def add_to_cart
    product = add_to_cart_params
    cart = []
    found = false
    if !session[:_current_user_cart].present?
      cart.push({ product_id: product[:product_id], quantity: 1, added_on: DateTime.now() });
    else
      cart = session[:_current_user_cart];
      cart.each do |item|
        if (item[:product_id] == product[:product_id])
          item[:quantity] = item[:quantity] + 1
          found = true
        end
      end
      if !found
        cart.push({ product_id: product[:product_id], quantity: 1, added_on: DateTime.now() });
      end
    end
    session[:_current_user_cart] = cart
  end

  def update_product_quantity
    product_params = update_product_quantity_params
    @product = Product.where(id: product_params[:product_id]).first
    @cart_item = ''
    if @product.present?
      @cart = get_cart
      @cart.each do |item|
        if item[:product_id].to_i == @product.id
          @cart_item = item
          if product_params[:action] == 'increase' && @product.stock >= (item[:quantity]+1)
            item[:quantity] = item[:quantity] + 1
          else # else if the coming param is decrease
            if (item[:quantity] - 1) < 1
              # remove this item from session[:_current_user_cart]
              @cart.delete_if { |h| h[:product_id].to_i == @product.id }
            else
              item[:quantity] = item[:quantity] - 1
            end
          # else
            # show notice something went wrong
            # break
          end
        end
      end
      session[:_current_user_cart] = @cart
    else
      # show notice something went wrong
      return
    end
  end

  def update_product_quantity_by_number
    update_product_quantity_by_number = update_product_quantity_by_number_params
    @product = Product.where(id: update_product_quantity_by_number[:product_id]).first
    @cart = ''
    @cart_item = ''
    if @product.present?
      @cart = get_cart
      @cart.map { |h| 
        if h[:product_id].to_i == @product.id
          @cart_item = h
          h[:quantity] = update_product_quantity_by_number[:quantity].to_i
        end
      }
      session[:_current_user_cart] = @cart
    end
  end

  def remove_product_form_cart
    remove_product_params = remove_product_from_cart_params
    @product = Product.where(id: remove_product_params[:product_id]).first
    if @product.present?
      @cart = get_cart
      @cart.delete_if { |h| h[:product_id].to_i == @product.id }
    end
  end

  private
  def get_cart
    @cart = session[:_current_user_cart] ||= []
  end

  def add_to_cart_params
    params.require(:product).permit(:product_id)
  end

  def update_product_quantity_params
    params.require(:product_quantity).permit(:product_id, :action)
  end

  def update_product_quantity_by_number_params
    params.require(:product_quantity).permit(:product_id, :quantity)
  end

  def remove_product_from_cart_params
    params.require(:remove_product).permit(:product_id)
  end
end
