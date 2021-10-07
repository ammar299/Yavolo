$(document).on('turbolinks:load', function(){

  $('#delete-delivery-options').click(deleteDeliveryOption);
  $('.select-all-container #select-all').change(selectedDeliveryOptions);
});

function deleteDeliveryOption() {
  selected_delivery_options = []
  $('.select-checkbox-container input[type=checkbox]:checked').each(function() {
    selected_delivery_options.push($(this).val())
  });
  if (selected_delivery_options.length > 0) {
    url = '/admin/delivery_options/delete_delivery_options?ids=' + selected_delivery_options
    $.ajax({
      url: url,
      type: 'DELETE'
    });
  }
}

function selectedDeliveryOptions() {
  if ($('#select-all').is(':checked')) {
    $('.select-checkbox-container input[type=checkbox]').prop('checked', true)
  } else {
    $('.select-checkbox-container input:checkbox').prop('checked', false)
  }
}