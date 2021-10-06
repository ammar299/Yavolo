$(document).on('turbolinks:load', function(){
  $('#delete-delivery-options').click(function(){
    selected_deliery_option = []
    $('.select-checkbox-container input[type=checkbox]:checked').each(function() {
      selected_deliery_option.push($(this).val())
    });
    if (selected_deliery_option.length > 0) {
      url = '/admin/delivery_options/delete_delivery_options?ids=' + selected_deliery_option
      $.ajax({
        url: url,
        type: 'DELETE'
      });
    }
  });

  $('.select-all-container #select-all').change(function() {
    if ($('#select-all').is(':checked')) {
      $('.select-checkbox-container input[type=checkbox]').prop('checked', true)
    } else {
      $('.select-checkbox-container input:checkbox').prop('checked', false)
    }
  });
});
