$(document).ready(function(){
  deleteDeliveryOptionsCarriers();
  deleteDeliveryOptionsForSellers();
  deliveryOptionDropdownValidation();
  addNewCarrierFormValidation();
  $('.delivery-options-select-all-container #delivery-option-select-all').change(() => selectedDeliveryOptionsCarriers('.delivery-options-checkbox-container'));
  $('.carriers-select-all-container #carrier-select-all').change(() => selectedDeliveryOptionsCarriers('.carriers-checkbox-container'));

});

function addNewCarrierFormValidation() {

  $('form#add_new_carrier_form').validate({
    ignore: "", 
    rules: {
      "carrier[name]": {
        required: true
      },
      "carrier[api_key]": {
        required: true
      },
      "carrier[secret_key]": {
        required: true
      }
    }, 
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "carrier[name]": {
          required: "Name is required"
      },
      "carrier[api_key]": {
        required: "API Key is required"
      },
      "carrier[secret_key]": {
        required: "Secret Key is required"
      }
    }
  });

}

window.setFormValidation = function(){
  
  $('form#delivery_option_form').validate({
    ignore: "", 
    rules: {
      "delivery_option[name]": {
        required: true
      },
      "delivery_option[processing_time]": {
        required: true
      },
      "delivery_option[delivery_time]": {
        required: true
      }
    }, 
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "delivery_option[name]": {
          required: "Delivery Option is required"
      },
      "delivery_option[processing_time]": {
        required: "Processing Time is required"
      },
      "delivery_option[delivery_time]": {
        required: "Delivery Time is required"
      }
    }
  });
}

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

function deliveryOptionDropdownValidation() {
	$('body').on('change', '#delivery_option_processing_time, #delivery_option_delivery_time', function () {
    labelId = $(this).is("#delivery_option_processing_time")? '#delivery_option_processing_time-error' : '#delivery_option_delivery_time-error'
    if ($(this).val() != '') {
      $(this).parents("div.form-group").removeClass('error-field');
      $(labelId).text('');
      $(labelId).css('display', 'd-none');
    } else {
      $(this).parents("div.form-group").addClass('error-field');
      labeltext = $(this).is("#delivery_option_processing_time")? 'Processing Time is Required' : 'Delivery Time is Required'
      $(labelId).text(labeltext);
      $(labelId).css('display', 'block');
    }
	});
}
