$(document).ready(function(){
  console.log('sellers js is loaded');
  $('#approve-sellers').click(() => sellersMultipleUpdate('.multiple-update-sellers','approve'));
  $('#suspend-sellers').click(() => sellersMultipleUpdate('.multiple-update-sellers','suspend'));
  $('#delete-sellers').click(() => sellersMultipleUpdate('.multiple-update-sellers','delete'));
  $('#activate-sellers').click(() => sellersMultipleUpdate('.multiple-update-sellers','activate'));
  $('#send-password-reset-email-sellers').click(() => sellersMultipleUpdate('.multiple-update-sellers','send_password_reset_email'));
});

function sellersMultipleUpdate(className, action) {
  selected_sellers = []
  $(className + ' ' + 'input[type=checkbox]:checked').each(function () {
    selected_sellers.push($(this).val())
  });

  if (selected_sellers.length > 0) {
    path = 'sellers/update_multiple'
    url = '/admin/' + path + '?' + 'seller_ids=' + selected_sellers + '&field_to_update=' + action
    $.ajax({
      url: url,
      type: 'GET'
    });
  }
}