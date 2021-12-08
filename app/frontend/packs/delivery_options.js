$(document).ready(function(){
  deleteDeliveryOptionsCarriers();
  deleteDeliveryOptionsForSellers();
  addNewCarrierFormValidation();
  submitDeliveryForm(); // check fields are valid or not and then submit form
  enableDeliveryOptionName(); // enable/disable name validation after form submit
  deliveryOptionDropdownValidation(); // enable/disable select filed validation after form submit
  enableDeliveryShipAttributes(); // enable and disable ship attributes on checked
  setSellerDeliveryOptionSearchMenuAndQueryName();
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

// check fields are valid or not and then submit form
function submitDeliveryForm() {
  $('body').on('click', '#delivery-option-form-btn', function(event) {
    event.preventDefault();
    var name_field = $('#delivery_option_name');
    var non_empty_name_filed = (name_field.val() != '');
    var processing_time_count = 0;
    var delivery_time_count = 0;
    $('#delivery-option-form input[type=checkbox]').each(function () {
      if (this.checked) {
        accessShipsAttributesClasses($(this));
        if ($('.' + processing_time_klass).val() == '') {
          processing_time_count += 1;
        }
        if ($('.' + delivery_time_klass).val() == '') {
          delivery_time_count += 1;
        }
      }
    });
    if ((non_empty_name_filed == true) && (processing_time_count == 0) && (delivery_time_count == 0)) {
      $('#delivery-option-form-btn').attr('id', 'delivery-option-submit-btn');
      $('#delivery-option-form input[type=checkbox]').each(function () {
        accessShipsAttributesClasses($(this));
        $('.' + processing_time_klass).attr('disabled', false);
        $('.' + delivery_time_klass).attr('disabled', false);
      });
      $('#delivery-option-submit-btn').trigger('click');
    } else {
      if (name_field.val() == '') {
        name_field.parents("div.form-group").addClass('error-field');
        name_field.parent().find('#delivery-option-name-error-label').html('<label id="delivery_option_name_-error" class="error" for="delivery_option_time_"></label>');
        $('#delivery_option_name_-error').text('Required');
      }
      $('#delivery-option-form input[type=checkbox]').each(function () {
        if (this.checked) {
          accessShipsAttributesClasses($(this));
          if ($('.' + processing_time_klass).val() == '') {
            $('.' + processing_time_klass).parents("div.form-group").addClass('error-field');
            $('#' + processing_time_klass + '-error-label').html('<label id="'+ processing_time_klass +'-error-text" class="error" for="ship_processing_time_"></label>');
            $('#' + processing_time_klass + '-error-text').text('Required');
          }
          if ($('.' + delivery_time_klass).val() == '') {
            $('.' + delivery_time_klass).parents("div.form-group").addClass('error-field');
            $('#' + delivery_time_klass +'-error-label').html('<label id="'+ delivery_time_klass +'-error-text" class="error" for="ship_processing_time_"></label>');
            $('#' + delivery_time_klass + '-error-text').text('Required');
          }
        }
      });
    }
  });
}

function accessShipsAttributesClasses($this) {
  processing_time_klass = $this.data('processingShipId');
  delivery_time_klass = $this.data('deliveryShipId');
}

// enable/disable name validation after form submit
function enableDeliveryOptionName() {
  $('body').on('input', '#delivery_option_name', function() {
    if ($(this).parent().find('#delivery_option_name_-error').length > 0) {
      if ($(this).val() != '') {
        $(this).parents("div.form-group").removeClass('error-field');
        $('#delivery_option_name_-error').text('');
      } else {
        $(this).parents("div.form-group").addClass('error-field');
        $('#delivery_option_name_-error').text('Required');
      }
    }
  });
}

// enable/disable select filed validation after form submit
function deliveryOptionDropdownValidation() {
	$('body').on('change', '#select-ship-processing-time, #select-ship-delivery-time', function () {
    klass = $(this).attr('class').split(' ')[1]
    if (($(this).val() != '') && ($(this).parent().find('#' + klass + '-error-label').length > 0)) {
      $(this).parents("div.form-group").removeClass('error-field');
      $('#' + klass + '-error-text').text('');
    } else if (($(this).val() == '') && ($(this).parent().find('#' + klass + '-error-label').length > 0)) {
      $(this).parents("div.form-group").addClass('error-field');
      $('#' + klass + '-error-text').text('Required');
    }
	});
}

// This function is use for enable and disable ship attributes on checked
function enableDeliveryShipAttributes() {
	$('body').on('change', '#ship-checkbox', function() {
    if ($(this).next().next().text() == 'UK Mainland') {
      $(this).prop('checked', true);
      return
    }
    accessShipsAttributesClasses($(this));
    if (this.checked) {
      $('.' + processing_time_klass).attr('disabled', false);
      $('.' + delivery_time_klass).attr('disabled', false);
    } else {
      $('.' + processing_time_klass).attr('disabled', true);
      $('.' + delivery_time_klass).attr('disabled', true);
      $('.' + processing_time_klass).parents("div.form-group").removeClass('error-field');
      $('#' + processing_time_klass + '-error-text').text('');
      $('.' + delivery_time_klass).parents("div.form-group").removeClass('error-field');
      $('#' + delivery_time_klass + '-error-text').text('');
    }
  });
}

function setSellerDeliveryOptionSearchMenuAndQueryName(){
  $('.seller-delivery-options-filters a').click(function(e) {
    e.preventDefault();
    let currentFilter = $(this).text().trim();
    let searchField = $('.seller-delivery-option-search-field');
    let filterType = $('#delivery-option-filter-type');
    $('.seller-delivery-options-filters a').each(function( index ) {
      $(this).find('.fa-check').addClass('d-none');
    });
    $(this).find('.fa-check').removeClass('d-none');
    if(currentFilter=='Delivery Name'){
      searchField.attr('name', 'q[name_cont]');
      $('#csfn').val('name_cont');
      filterType.val('Delivery Name');
    }else{
      $('.current-search-filter').text('Search All');
      searchField.attr('name', 'q[name_or_ships_name_cont]');
      $('#csfn').val('name_or_ships_name_cont');
      filterType.val('Search All');
    }
    $('.current-search-filter').html(currentFilter+' <i class="fa fa-angle-down ml-2" aria-hidden="true"></i>');
  });
}
