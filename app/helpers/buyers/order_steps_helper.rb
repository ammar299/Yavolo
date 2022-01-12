module Buyers::OrderStepsHelper

  def order_date_format(order)
    date = order.created_at
    date = date.strftime("#{date.day.ordinalize} %B %Y")
    date
  end

  def product_owner(line_item)
    line_item.product.owner.company_detail.name
  end

  def order_thumbnail_image(item,version = :thumb)
    if item.product.pictures&.first&.name&.url&.present?
      item.product.pictures.first.name.url(version)
    else
      'default.jpg'
    end
  end

end
