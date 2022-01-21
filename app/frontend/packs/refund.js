$(document).ready(function () {
  console.log("Refund js is loaded");
  validateRefundAmountForm();
  maskCurrencyWithInput();
});

function maskCurrencyWithInput() {
    $('[name^="refund[refund_details_attributes]"]').each(function (childNodeValue, element) {
      addCurrencyFieldInInput(element.id)
    });
}

jQuery.validator.addMethod(
  "validate_refund_price_with_actual_price",
  function (value, element) {
    let paidValue = $(`input[name='1${element.name}1'`).val();
    let count = 0
    $('[name^="refund[refund_details_attributes]"]').each(function (childNodeValue, element) {
      let elementId = element.id;
      let elementValue = $(`#${elementId}`).val();
      $(`#${elementId}-error`).remove()
      $(`#${elementId}`).removeClass('error')
      if (isNaN(elementValue) === false && parseFloat(elementValue) > 0) {
        count++
      }
    })
    return count > 0 || parseFloat(value) <= parseFloat(paidValue);

  },
  "Refund amount should be between 0 and actual paid amount"
);

function validateRefundAmountForm() {
  $('form#new_refund').validate({
  });
  $('[name*="refund[refund_details_attributes]"]').each(function () {
    $(this).rules('add', {
      validate_refund_price_with_actual_price: true,
      messages: {
        required: "Refund amount should be between 0 and actual paid amount"
      }
    });
  });
}

