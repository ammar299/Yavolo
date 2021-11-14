$(document).ready(function(){
  console.log('sellers js is loaded');
  onBoardingApiScript();
  sellerOnBoarding();
  sellerSearchByFilter();
  addNewSellerFormValidation();
  newSellerFormDropdownValidation();
  validateEligibility();
  loginSettingsForm();
  validateSellerSignInSignUp();
  sellerTimeOutSlector()
  //Upload Sellers
  $(".upload-sellers-csv-btn").click(function () {
    $("#upload-sellers-csv-popup").modal("show");
  });
  uploadCsvDragDrop()
  function addNewSellerFormValidation() {

    $('form#add_new_seller_form').validate({
      ignore: "", 
      rules: {
        "seller[email]": {
          required: true
        },
        "seller[company_detail_attributes][name]": {
          required: true
        },
        "seller[company_detail_attributes][country]": {
          required: true
        },
        "seller[company_detail_attributes][legal_business_name]": {
          required: true
        },
        "seller[company_detail_attributes][companies_house_registration_number]": {
          required: true
        },
        "seller[company_detail_attributes][doing_business_as]": {
          required: true
        },
        "seller[company_detail_attributes][business_industry]": {
          required: true
        },
        "seller[company_detail_attributes][website_url]": {
          required: true,
          url_without_scheme: true
        },
        "seller[company_detail_attributes][amazon_url]": {
          required: true,
          url_without_scheme: true
        },
        "seller[company_detail_attributes][ebay_url]": {
          required: true,
          url_without_scheme: true
        },
        "seller[company_detail_attributes][vat_number]": {
          required: true
        },
        "seller[addresses_attributes][0][address_line_1]": {
          required: true
        },
        "seller[addresses_attributes][0][address_line_2]": {
          required: true
        },
        "seller[addresses_attributes][0][city]": {
          required: true
        },
        "seller[addresses_attributes][0][county]": {
          required: true
        },
        "seller[addresses_attributes][0][postal_code]": {
          required: true,
          postal_code_uk: true
        },
        "seller[addresses_attributes][0][country]": {
          required: true
        },
        "seller[addresses_attributes][0][phone_number]": {
          required: true,
          phone_number_uk: true
        },
        "seller[business_representative_attributes][full_legal_name]": {
          required: true
        },
        "seller[business_representative_attributes][email]": {
          required: true
        },
        "seller[business_representative_attributes][job_title]": {
          required: true
        },
        "seller[business_representative_attributes][date_of_birth]": {
          required: true
        },
        "seller[addresses_attributes][1][address_line_1]": {
          required: true
        },
        "seller[addresses_attributes][1][address_line_2]": {
          required: true
        },
        "seller[addresses_attributes][1][city]": {
          required: true
        },
        "seller[addresses_attributes][1][county]": {
          required: true
        },
        "seller[addresses_attributes][1][postal_code]": {
          required: true,
          postal_code_uk: true
        },
        "seller[addresses_attributes][1][country]": {
          required: true
        },
        "seller[addresses_attributes][1][phone_number]": {
          required: true,
          phone_number_uk: true
        },
        "seller[subscription_type]": {
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
        "seller[email]": {
            required: "Email is required"
        },
        "seller[company_detail_attributes][name]": {
          required: "Company name is required"
        },
        "seller[company_detail_attributes][country]": {
          required: "Country name is required"
        },
        "seller[company_detail_attributes][legal_business_name]": {
          required: "Legal business name is required"
        },
        "seller[company_detail_attributes][companies_house_registration_number]": {
          required: "Registration number is required"
        },
        "seller[company_detail_attributes][doing_business_as]": {
          required: "This field is required"
        },
        "seller[company_detail_attributes][business_industry]": {
          required: "Business industry is required"
        },
        "seller[company_detail_attributes][website_url]": {
          required: "Website URL is required"
        },
        "seller[company_detail_attributes][amazon_url]": {
          required: "Amazon URL is required"
        },
        "seller[company_detail_attributes][ebay_url]": {
          required: "ebay URL is required"
        },
        "seller[company_detail_attributes][vat_number]": {
          required: "VAT number is required"
        },
        "seller[addresses_attributes][0][address_line_1]": {
          required: "Address is required"
        },
        "seller[addresses_attributes][0][address_line_2]": {
          required: "Address is required"
        },
        "seller[addresses_attributes][0][city]": {
          required: "City is required"
        },
        "seller[addresses_attributes][0][county]": {
          required: "County is required"
        },
        "seller[addresses_attributes][0][postal_code]": {
          required: "Postal Code is required"
        },
        "seller[addresses_attributes][0][country]": {
          required: "Country name is required"
        },
        "seller[addresses_attributes][0][phone_number]": {
          required: "Phone number is required"
        },
        "seller[business_representative_attributes][full_legal_name]": {
          required: "Full legal name is required"
        },
        "seller[business_representative_attributes][email]": {
          required: "Email is required"
        },
        "seller[business_representative_attributes][job_title]": {
          required: "Job title is required"
        },
        "seller[business_representative_attributes][date_of_birth]": {
          required: "Date of Birth is required"
        },
        "seller[addresses_attributes][1][address_line_1]": {
          required: "Address is required"
        },
        "seller[addresses_attributes][1][address_line_2]": {
          required: "Address is required"
        },
        "seller[addresses_attributes][1][city]": {
          required: "City is required"
        },
        "seller[addresses_attributes][1][county]": {
          required: "County is required"
        },
        "seller[addresses_attributes][1][postal_code]": {
          required: "Postal code is required"
        },
        "seller[addresses_attributes][1][country]": {
          required: "Country name is required"
        },
        "seller[addresses_attributes][1][phone_number]": {
          required: "Phone number is required"
        },
        "seller[subscription_type]": {
          required: "Subscription type is required"
        }
      },
    });
    jQuery.validator.addMethod("url_without_scheme", function(value, element) {
        return /^(?:www\.)?[A-Za-z0-9_-]+\.+[A-Za-z0-9.\/%&=\?_:;-]+$/.test(value);
        }, "Please enter a valid URL without http/https"
    );

    jQuery.validator.addMethod("postal_code_uk", function (value, element) {
      return this.optional(element) || /^[A-Z]{1,2}[0-9]{1,2} [0-9][A-Z]{2}$/i.test(value);
    }, "Please specify a valid UK postal code");

    jQuery.validator.addMethod('phone_number_uk', function(value, element) {
          return this.optional(element) || value.length > 9 && value.match(/^(\(?(0|\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/);
        }, 'Please specify a valid UK phone number'
    );
  }

  function loginSettingsForm() {
     $('form#add_new_seller_profile_form').validate({
      ignore: "", 
      rules: {
        "seller[email]": {
          required: true
        },
        "seller[contact_number]": {
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
        "seller[email]": {
            required: "Email is required"
        },
        "seller[contact_number]": {
          required: "Contact number is required"
        }
      }
    });
  }

  $("#check-all-checkboxes").click(function () {
    if ($(this).is(":checked")) {
      $("input:checkbox").not(this).prop("checked", true);
    } else {
      $("input:checkbox").not(this).prop("checked", false);
    }
  });

  $("#csv_import_sellers_file").change(function (e) {
    let files = e.target.files;
    let fileValidator = validCsvFile(files);
    if (fileValidator.isValid) {
      $("#upload-sellers-csv-popup .modal-body").find(".file-errors").remove();
      uploadCSVFile(files);
    } else {
      document.getElementById("csv_import_sellers_file").value = "";
      $("#upload-sellers-csv-popup .modal-body").find(".file-errors").remove();
      $("#upload-sellers-csv-popup .modal-body").append(
        '<ul class="file-errors" style="color: red;">' +
          fileValidator.errors.map((e) => "<li>" + e + "</li>").join("") +
          "</ul>"
      );
    }
  });

});

function validCsvFile(files) {
  let allowedExtensions = /(\.csv)$/i;
  let errors = [];
  if (!allowedExtensions.exec(files[0].name)) {
    errors.push("Invalid file type, allowed type is .csv");
  }
  let size = files[0].size / 1024 / 1024;

  if (size > 10) {
    errors.push("File size should be less than 10MB");
  }
  return { errors: errors, isValid: !(errors.length > 0) };
}

function uploadCSVFile(files) {
  $("#csv_import_sellers_file").attr("disabled", true);
  let url = "YOUR URL HERE";
  let formData = new FormData();
  formData.append("csv_import_sellers[file]", files[0]);
  $.ajax({
    url: "/admin/import_sellers",
    type: "POST",
    data: formData,
    processData: false, // tell jQuery not to process the data
    contentType: false, // tell jQuery not to set contentType
    success: function (res) {
      $("#upload-sellers-csv-popup").modal("hide");
      $("#upload-sellers-csv-success-popup").modal("show");
      $('#csv_import_sellers_file').attr('disabled', false);
    },
    error: function (xhr) {
      document.getElementById("csv_import_file").value = "";
      $("#upload-sellers-csv-popup .modal-body").find(".file-errors").remove();
      $("#upload-sellers-csv-popup .modal-body").append(
        '<ul class="file-errors" style="color: red;">' +
          [xhr.responseJSON.errors].map((e) => "<li>" + e + "</li>").join("") +
          "</ul>"
      );
      // hide any loading image
      $("#csv_import_sellers_file").attr("disabled", false);
    },
  });
}

function sellersMultipleUpdate(className, action) {
  selected_sellers = [];
  $(className + " " + "input[type=checkbox]:checked").each(function () {
    selected_sellers.push($(this).val());
    $("#check-all-checkboxes").click(function () {
      if ($(this).is(":checked")) {
        $("input:checkbox").not(this).prop("checked", true);
      } else {
        $("input:checkbox").not(this).prop("checked", false);
      }
    });
  });
}

function sellerSearchByFilter() {
  var $sellerDropDown = $(".seller-search-dropdown");
  var $sellerSearchField = $(".seller-search-field");
  var $sellerFilterTypeField = $("#seller-filter-type");
  $("#seller-serarch-by-toggle a").click(function (e) {
    var $currFilter = $(this).text().trim();
    $('.seller-listing-filters a').removeClass('active');
    $(this).addClass('active')
    e.preventDefault();
    $sellerDropDown.text($(this).text());
    $sellerDropDown.append('<i class="fa fa-angle-down ml-4" aria-hidden="true"></i>')
    if ($currFilter === "Username") {
      $sellerSearchField.attr("name", "q[first_name_or_last_name_cont]");
      $sellerFilterTypeField.val("Username");
    } else if ($currFilter === "Email") {
      $sellerSearchField.attr("name", "q[email_cont]");
      $sellerFilterTypeField.val("Email");
    } else {
      $sellerSearchField.attr(
        "name",
        "q[first_name_or_last_name_or_email_cont]"
      );
      $sellerFilterTypeField.val("Search All");
    }
  });
}

function sellerOnBoarding(){
  let searchParams = new URLSearchParams(window.location.search)
  if (searchParams.has('merchantId') == true)
  {
    let merchantId = searchParams.get('merchantId')
    let merchantIdInPayPal = searchParams.get('merchantIdInPayPal')
    let consentStatus = searchParams.get('consentStatus')
    let productIntentId = searchParams.get('productIntentId')
    let isEmailConfirmed = searchParams.get('isEmailConfirmed')
    // console.log("params=>",merchantId,"   ",merchantIdInPayPal)
    let host_url = process.env.DEFAULT_HOST_URL
    $.ajax({
      url: "/sellers/check_onboarding_status",
      type: "POST",
      data : { merchantId : merchantId, merchantIdInPayPal : merchantIdInPayPal},
      success: function(response){
        notify(response,host_url)
      },
      error: function () {
        $("#paypal-integration-failure").addClass("notice-msg")
        window.location.href = "https://"+host_url+"/sellers/paypal_integration";
      }
    });
  }
}

function onBoardingApiScript(){
  (function(d, s, id) {
    var js, ref = d.getElementsByTagName(s)[0];
    if (!d.getElementById(id)) {
      js = d.createElement(s);
      js.id = id;
      js.async = true;
      js.src = "https://www.paypal.com/webapps/merchantboarding/js/lib/lightbox/partner.js";
      ref.parentNode.insertBefore(js, ref);
    }
  }(document, "script", "paypal-js"));
}

function notify(response,host_url){
  if (response.status == true){
    $("#paypal-integration-success").addClass("notice-msg")
    setTimeout(function(){
      window.location.href = "https://"+host_url+"/sellers";
    }, 5000)
  }
  else{
    $("#paypal-integration-failure").addClass("notice-msg")
    setTimeout(function(){
      window.location.href = "https://"+host_url+"/sellers/paypal_integration";
    }, 5000);
    
  }
}
function newSellerFormDropdownValidation() {
	$('body').on('change', '#seller_company_detail_attributes_country, #seller_addresses_attributes_0_country, #seller_addresses_attributes_1_country', '#seller_subscription_type', function () {
    labelId = $(this).is("#seller_company_detail_attributes_country")? '#seller_company_detail_attributes_country-error' : $(this).is("#seller_addresses_attributes_0_country")?'#seller_addresses_attributes_0_country-error' : $(this).is("#seller_addresses_attributes_1_country")? '#seller_addresses_attributes_1_country-error' : '#seller_subscription_type-error'
    if ($(this).val() != '') {
      $(this).parents("div.form-group").removeClass('error-field');
      $(labelId).text('');
      $(labelId).css('display', 'd-none');
    } else {
      $(this).parents("div.form-group").addClass('error-field');
      labeltext = $(this).is("#seller_company_detail_attributes_country")? 'Country name is required' : $(this).is("#seller_addresses_attributes_0_country")? 'Country name is required' : $(this).is('#seller_addresses_attributes_1_country')? 'Country name is required' : 'Subscription type is required'
      $(labelId).text(labeltext);
      $(labelId).css('display', 'block');
    }
	});
}

window.validateSellerEditForm = function() {
  $('form#admin-sellers-update-form').validate({
    ignore: "", 
    rules: {
      "seller[email]": {
        required: true
      },
      "seller[company_detail_attributes][name]": {
        required: true
      },
      "seller[company_detail_attributes][country]": {
        required: true
      },
      "seller[company_detail_attributes][legal_business_name]": {
        required: true
      },
      "seller[company_detail_attributes][companies_house_registration_number]": {
        required: true
      },
      "seller[company_detail_attributes][doing_business_as]": {
        required: true
      },
      "seller[company_detail_attributes][business_industry]": {
        required: true
      },
      "seller[company_detail_attributes][website_url]": {
        required: true,
        url_without_scheme: true
      },
      "seller[company_detail_attributes][amazon_url]": {
        required: true,
        url_without_scheme: true
      },
      "seller[company_detail_attributes][ebay_url]": {
        required: true,
        url_without_scheme: true
      },
      "seller[company_detail_attributes][vat_number]": {
        required: true
      },
      "seller[addresses_attributes][0][address_line_1]": {
        required: true
      },
      "seller[addresses_attributes][0][address_line_2]": {
        required: true
      },
      "seller[addresses_attributes][0][city]": {
        required: true
      },
      "seller[addresses_attributes][0][county]": {
        required: true
      },
      "seller[addresses_attributes][0][postal_code]": {
        required: true,
        postal_code_uk: true
      },
      "seller[addresses_attributes][0][country]": {
        required: true
      },
      "seller[addresses_attributes][0][phone_number]": {
        required: true,
        phone_number_uk: true
      },
      "seller[business_representative_attributes][full_legal_name]": {
        required: true
      },
      "seller[business_representative_attributes][email]": {
        required: true
      },
      "seller[business_representative_attributes][job_title]": {
        required: true
      },
      "seller[business_representative_attributes][date_of_birth]": {
        required: true
      },
      "seller[addresses_attributes][1][address_line_1]": {
        required: true
      },
      "seller[addresses_attributes][1][address_line_2]": {
        required: true
      },
      "seller[addresses_attributes][1][city]": {
        required: true
      },
      "seller[addresses_attributes][1][county]": {
        required: true
      },
      "seller[addresses_attributes][1][postal_code]": {
        required: true,
        postal_code_uk: true
      },
      "seller[addresses_attributes][1][country]": {
        required: true
      },
      "seller[addresses_attributes][1][phone_number]": {
        required: true,
        phone_number_uk: true
      },
      "seller[subscription_type]": {
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
      "seller[email]": {
          required: "Email is required"
      },
      "seller[company_detail_attributes][name]": {
        required: "Company name is required"
      },
      "seller[company_detail_attributes][country]": {
        required: "Country name is required"
      },
      "seller[company_detail_attributes][legal_business_name]": {
        required: "Legal business name is required"
      },
      "seller[company_detail_attributes][companies_house_registration_number]": {
        required: "Registration number is required"
      },
      "seller[company_detail_attributes][doing_business_as]": {
        required: "This field is required"
      },
      "seller[company_detail_attributes][business_industry]": {
        required: "Business industry is required"
      },
      "seller[company_detail_attributes][website_url]": {
        required: "Website URL is required"
      },
      "seller[company_detail_attributes][amazon_url]": {
        required: "Amazon URL is required"
      },
      "seller[company_detail_attributes][ebay_url]": {
        required: "ebay URL is required"
      },
      "seller[company_detail_attributes][vat_number]": {
        required: "VAT number is required"
      },
      "seller[addresses_attributes][0][address_line_1]": {
        required: "Address is required"
      },
      "seller[addresses_attributes][0][address_line_2]": {
        required: "Address is required"
      },
      "seller[addresses_attributes][0][city]": {
        required: "City is required"
      },
      "seller[addresses_attributes][0][county]": {
        required: "County is required"
      },
      "seller[addresses_attributes][0][postal_code]": {
        required: "Postal Code is required"
      },
      "seller[addresses_attributes][0][country]": {
        required: "Country name is required"
      },
      "seller[addresses_attributes][0][phone_number]": {
        required: "Phone number is required"
      },
      "seller[business_representative_attributes][full_legal_name]": {
        required: "Full legal name is required"
      },
      "seller[business_representative_attributes][email]": {
        required: "Email is required"
      },
      "seller[business_representative_attributes][job_title]": {
        required: "Job title is required"
      },
      "seller[business_representative_attributes][date_of_birth]": {
        required: "Date of Birth is required"
      },
      "seller[addresses_attributes][1][address_line_1]": {
        required: "Address is required"
      },
      "seller[addresses_attributes][1][address_line_2]": {
        required: "Address is required"
      },
      "seller[addresses_attributes][1][city]": {
        required: "City is required"
      },
      "seller[addresses_attributes][1][county]": {
        required: "County is required"
      },
      "seller[addresses_attributes][1][postal_code]": {
        required: "Postal code is required"
      },
      "seller[addresses_attributes][1][country]": {
        required: "Country name is required"
      },
      "seller[addresses_attributes][1][phone_number]": {
        required: "Phone number is required"
      },
      "seller[subscription_type]": {
        required: "Subscription type is required"
      }
    },
  });
  jQuery.validator.addMethod("url_without_scheme", function(value, element) {
        return /^(?:www\.)?[A-Za-z0-9_-]+\.+[A-Za-z0-9.\/%&=\?_:;-]+$/.test(value);
      }, "Please enter a valid URL without http/https"
  );

  jQuery.validator.addMethod("postal_code_uk", function (value, element) {
    return this.optional(element) || /^[A-Z]{1,2}[0-9]{1,2} [0-9][A-Z]{2}$/i.test(value);
  }, "Please specify a valid UK postal code");

  jQuery.validator.addMethod('phone_number_uk', function(value, element) {
        return this.optional(element) || value.length > 9 && value.match(/^(\(?(0|\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/);
      }, 'Please specify a valid UK phone number'
  );
}


function validateSellerSignInSignUp() {
  $('form#new_seller').validate({
    ignore: "", 
    rules: {
      "seller[first_name]": {
        required: true
      },
      "seller[last_name]": {
        required: true
      },
      "seller[email]": {
        required: true
      },
      "seller[password]": {
        required: true
      },
      "seller[password_confirmation]": {
        required: true
      },
    }, 
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "seller[first_name]": {
        required: "First name is required"
      },
      "seller[last_name]": {
        required: "Last name is required"
      },
      "seller[email]": {
          required: "Email is required"
      },
      "seller[password]": {
        required: "Password is required"
      },
      "seller[password_confirmation]": {
        required: "Password confirmation is required"
      },
    },
  });
}

function sellerTimeOutSlector() {
  $('body').on('click', ".time-out-session", function () {
    $("#seller_timeout").val().length > 1
    if ($(this).is(":checked"))
    {
      $('.logout-time-dropdown').removeClass('d-none');
      // $(".seller-selector").show()
    } else {
      $('.logout-time-dropdown').addClass('d-none');
      // $(".seller-selector").hide()
      $(".selector-value").val('')
    }
  })
}

function validateEligibility () {
  $('body').on('click', ".not-eligible-toast", function () {
    $('#flash-msg').find('p').remove();
    var toast = '<p class="flash-toast notice notice-msg">Please complete your dashboard required steps! <span  class="notice-cross-icon" aria-hidden="true">&times;</span> </p>'
    $('#flash-msg').html(toast);
    setTimeout(function () {
      $("#flash-msg").find("p").remove();
    }, 3000);
  })
}

function uploadCsvDragDrop(){
  if(document.getElementById('upload-sellers-csv-popup'))
    bindDragAndDropEvents('upload-sellers-csv-popup');

}

function bindDragAndDropEvents(dropAreaId){
  let dropArea = document.getElementById(dropAreaId)
  ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false)
  })
  dropArea.addEventListener('drop', fileDropHandler, false)
}

function fileDropHandler(e){
  let dt = e.dataTransfer
  let files = dt.files;
  let fileValidator = validCsvFile(files);
  if(fileValidator.isValid){
    $('#upload-sellers-csv-popup .modal-body').find('.file-errors').remove();
    uploadCSVFile(files);
  }else{
    $('#upload-sellers-csv-popup.modal-body').find('.file-errors').remove();
    $('#upload-sellers-csv-popup .modal-body').append('<ul class="file-errors" style="color: red;">'+fileValidator.errors.map(e => '<li>'+e+'</li>').join("")+'</ul>')
  }
}

function preventDefaults (e) {
  e.preventDefault()
  e.stopPropagation()
}