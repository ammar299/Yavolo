module Admin::DeliveryOptionsHelper
  def select_processing_time
    DeliveryOption.processing_times.map {|k, v| [k.split('_').map(&:capitalize).join(' '), k]}
  end

  def select_delivery_time
    DeliveryOption.delivery_times.map {|k, v| [k.split('_').map(&:capitalize).join(' '), k]}
  end

  def template_processing_time(time)
    time.split('_').map(&:capitalize).join(' ')
  end
end
