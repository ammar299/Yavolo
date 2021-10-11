$(document).ready(function(){
  $('#delete-delivery-options').click(() => deleteDeliveryOptionsCarriers('.delivery-options-checkbox-container'));
  $('#delete-carriers').click(() => deleteDeliveryOptionsCarriers('.carriers-checkbox-container'));
  $('.delivery-options-select-all-container #delivery-option-select-all').change(() => selectedDeliveryOptionsCarriers('.delivery-options-checkbox-container'));
  $('.carriers-select-all-container #carrier-select-all').change(() => selectedDeliveryOptionsCarriers('.carriers-checkbox-container'));
});

function deleteDeliveryOptionsCarriers(className) {
  selected_delivery_options = []
  $(className + ' ' + 'input[type=checkbox]:checked').each(function() {
    selected_delivery_options.push($(this).val())
  });

  if (selected_delivery_options.length > 0) {
    path = className == '.delivery-options-checkbox-container' ? 'delivery_options/delete_delivery_options' : 'carriers/delete_carriers'
    url = '/admin/' + path + '?ids=' + selected_delivery_options
    $.ajax({
      url: url,
      type: 'DELETE'
    });
  }
}

function selectedDeliveryOptionsCarriers(className) {
  selectedCheckboxId = className == '.delivery-options-checkbox-container' ? '#delivery-option-select-all' : '#carrier-select-all'
  if ($(selectedCheckboxId).is(':checked')) {
    $(className + ' ' + 'input[type=checkbox]').prop('checked', true)
  } else {
    $(className + ' ' + 'input:checkbox').prop('checked', false)
  }
}
