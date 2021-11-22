module Admin::OrdersHelper

  def set_order_sort_by_in_dropdown(params)
    return 'Filter by' unless params.dig(:q, :s).present?
    case params.dig(:q, :s)
    when 'price'
      'Price'
    else
      'Filter by'
    end
  end
end
