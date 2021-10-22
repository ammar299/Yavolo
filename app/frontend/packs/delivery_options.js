$(document).ready(function(){
  deleteDeliveryOptionsCarriers();
  deleteDeliveryOptionsForSellers();
  $('.delivery-options-select-all-container #delivery-option-select-all').change(() => selectedDeliveryOptionsCarriers('.delivery-options-checkbox-container'));
  $('.carriers-select-all-container #carrier-select-all').change(() => selectedDeliveryOptionsCarriers('.carriers-checkbox-container'));
});

function deleteDeliveryOptionsCarriers(){
  $('body').on('click', '.delete-delivery-options, .delete-carriers', function(){
    klass = $(this).hasClass('delete-delivery-options') ? '.delivery-options-checkbox-container' : '.carriers-checkbox-container'
    selected_options = []
    $(klass + ' ' + 'input[type=checkbox]:checked').each(function() {
      selected_options.push($(this).val())
    });
    path = klass == '.delivery-options-checkbox-container' ? 'delivery_options/delete_delivery_options' : 'carriers/delete_carriers'
    url = '/admin/' + path + '?ids=' + selected_options
    $.ajax({
      url: url,
      type: 'DELETE'
    });
  });
}

function selectedDeliveryOptionsCarriers(className) {
  selectedCheckboxId = className == '.delivery-options-checkbox-container' ? '#delivery-option-select-all' : '#carrier-select-all'
  if ($(selectedCheckboxId).is(':checked')) {
    $(className + ' ' + 'input[type=checkbox]').prop('checked', true)
  } else {
    $(className + ' ' + 'input:checkbox').prop('checked', false)
  }
}

function deleteDeliveryOptionsForSellers(){
  $('body').on('click', '.delete-delivery-options-sellers', function(){
    selected_options = []
    $('.delivery-options-checkbox-container input[type=checkbox]:checked').each(function() {
      selected_options.push($(this).val())
    });
    url = '/sellers/delivery_options/delete_delivery_options' + '?ids=' + selected_options
    $.ajax({
      url: url,
      type: 'DELETE'
    });
  });
}