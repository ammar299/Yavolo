$(document).ready(function () {
  console.log("sign-up-steps js is loaded");
  addNewSellerFormValidation();
  newSellerFormDropdownValidation();
});

function addNewSellerFormValidation() {
  $("form#add_seller_steps").validate({
    ignore: "",
    rules: {
      "seller[email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      },
      "seller[company_detail_attributes][name]": {
        required: true,
      },
      "seller[company_detail_attributes][country]": {
        required: true,
      },
      "seller[company_detail_attributes][legal_business_name]": {
        required: true,
      },
      "seller[company_detail_attributes][companies_house_registration_number]":
        {
          required: true,
          companies_house_registration: true
        },
      "seller[company_detail_attributes][doing_business_as]": {
        required: true,
      },
      "seller[company_detail_attributes][business_industry]": {
        required: true,
      },
      "seller[company_detail_attributes][website_url]": {
        url_without_scheme: true
      },
      "seller[company_detail_attributes][amazon_url]": {
        url_without_scheme: true
      },
      "seller[company_detail_attributes][ebay_url]": {
        url_without_scheme: true
      },
      "seller[company_detail_attributes][vat_number]": {
        required: true,
        VAT_number_validation: true,
      },
      "seller[addresses_attributes][0][address_line_1]": {
        required: true,
      },
      "seller[addresses_attributes][0][address_line_2]": {
        required: true,
      },
      "seller[addresses_attributes][0][city]": {
        required: true,
      },
      "seller[addresses_attributes][0][county]": {
        required: true,
      },
      "seller[addresses_attributes][0][postal_code]": {
        required: true,
        postal_code_uk: true
      },
      "seller[addresses_attributes][0][country]": {
        required: true,
      },
      "seller[addresses_attributes][0][phone_number]": {
        required: true,
        phone_number_uk: true
      },
      "seller[business_representative_attributes][full_legal_name]": {
        required: true,
      },
      "seller[business_representative_attributes][email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      },
      "seller[business_representative_attributes][job_title]": {
        required: true,
      },
      "seller[business_representative_attributes][date_of_birth]": {
        required: true,
      },
      "seller[addresses_attributes][1][address_line_1]": {
        required: true,
      },
      "seller[addresses_attributes][1][address_line_2]": {
        required: true,
      },
      "seller[addresses_attributes][1][city]": {
        required: true,
      },
      "seller[addresses_attributes][1][county]": {
        required: true,
      },
      "seller[addresses_attributes][1][postal_code]": {
        required: true,
        postal_code_uk: true
      },
      "seller[addresses_attributes][1][country]": {
        required: true,
      },
      "seller[addresses_attributes][1][phone_number]": {
        required: true,
        phone_number_uk: true
      },
      "seller[subscription_type]": {
        required: true,
      },
      "seller[bank_detail_attributes][currency]": {
        required: true,
      },
      "seller[bank_detail_attributes][country]": {
        required: true,
      },
      "seller[bank_detail_attributes][sort_code]": {
        required: true,
        exactlength: 6,
      },
      "seller[bank_detail_attributes][account_number]": {
        required: true,
        exactlength: 8
      },
      "seller[bank_detail_attributes][account_number_confirmation]": {
        required: true,
        equalTo: "#seller_bank_detail_attributes_account_number"
      },
      "seller[terms_and_conditions]": {
        required: true,
      }
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      "seller[email]": {
        required: "Email is required",
      },
      "seller[company_detail_attributes][name]": {
        required: "Company name is required",
      },
      "seller[company_detail_attributes][country]": {
        required: "Country name is required",
      },
      "seller[company_detail_attributes][legal_business_name]": {
        required: "Legal business name is required",
      },
      "seller[company_detail_attributes][companies_house_registration_number]":
        {
          required: "Registration number is required",
        },
      "seller[company_detail_attributes][doing_business_as]": {
        required: "This field is required",
      },
      "seller[company_detail_attributes][business_industry]": {
        required: "Business industry is required",
      },
      "seller[company_detail_attributes][vat_number]": {
        required: "VAT number is required",
      },
      "seller[addresses_attributes][0][address_line_1]": {
        required: "Address is required",
      },
      "seller[addresses_attributes][0][address_line_2]": {
        required: "Address is required",
      },
      "seller[addresses_attributes][0][city]": {
        required: "City is required",
      },
      "seller[addresses_attributes][0][county]": {
        required: "County is required",
      },
      "seller[addresses_attributes][0][postal_code]": {
        required: "Postal Code is required",
      },
      "seller[addresses_attributes][0][country]": {
        required: "Country name is required",
      },
      "seller[addresses_attributes][0][phone_number]": {
        required: "Phone number is required",
      },
      "seller[business_representative_attributes][full_legal_name]": {
        required: "Full legal name is required",
      },
      "seller[business_representative_attributes][email]": {
        required: "Email is required",
      },
      "seller[business_representative_attributes][job_title]": {
        required: "Job title is required",
      },
      "seller[business_representative_attributes][date_of_birth]": {
        required: "Date of Birth is required",
      },
      "seller[addresses_attributes][1][address_line_1]": {
        required: "Address is required",
      },
      "seller[addresses_attributes][1][address_line_2]": {
        required: "Address is required",
      },
      "seller[addresses_attributes][1][city]": {
        required: "City is required",
      },
      "seller[addresses_attributes][1][county]": {
        required: "County is required",
      },
      "seller[addresses_attributes][1][postal_code]": {
        required: "Postal code is required",
      },
      "seller[addresses_attributes][1][country]": {
        required: "Country name is required",
      },
      "seller[addresses_attributes][1][phone_number]": {
        required: "Phone number is required",
      },
      "seller[subscription_type]": {
        required: "Subscription type is required",
      },
      "seller[bank_detail_attributes][currency]": {
        required: "Currency is required",
      },
      "seller[bank_detail_attributes][country]": {
        required: "Country is required",
      },
      "seller[bank_detail_attributes][sort_code]": {
        required: "Sort Code is required",
      },
      "seller[bank_detail_attributes][account_number]": {
        required: "Account Number is required",

      },
      "seller[bank_detail_attributes][account_number_confirmation]": {
        required: "Confirm Account Number is required",
        equalTo: "Confirm Account number should match Account number"
      },
      "seller[terms_and_conditions]": {
        required: "Please accept term & condtions",
      }
    },
  });

  jQuery.validator.addMethod("postal_code_uk", function (value, element) {
    return this.optional(element) || /^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$/.test(value);
  }, "Enter valid UK postal code");

  jQuery.validator.addMethod('phone_number_uk', function(value, element) {
        return this.optional(element) || value.length > 9 && value.match(/^(\(?(\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/);
      }, 'Enter valid UK phone number(e.g +447911123456)'
  );
jQuery.validator.addMethod("exactlength", function(value, element, param) {
 return this.optional(element) || value.length == param;
}, $.validator.format("Please enter exactly {0} characters."));
  jQuery.validator.addMethod(
      /* The value you can use inside the email object in the validator. */
      "regex",

      /* The function that tests a given string against a given regEx. */
      function(value, element, regexp)  {
        /* Check if the value is truthy (avoid null.constructor) & if it's not a RegEx. (Edited: regex --> regexp)*/

        if (regexp && regexp.constructor != RegExp) {
          /* Create a new regular expression using the regex argument. */
          regexp = new RegExp(regexp);
        }

        /* Check whether the argument is global and, if so set its last index to 0. */
        else if (regexp.global) regexp.lastIndex = 0;

        /* Return whether the element is optional or the result of the validation. */
        return this.optional(element) || regexp.test(value);
      },'Please enter a valid email address.'
  );
}
function newSellerFormDropdownValidation() {
  $('body').on('change', '#seller_company_detail_attributes_country, #seller_addresses_attributes_0_country, #seller_addresses_attributes_1_country', '#seller_bank_detail_attributes_country', function () {
    var id = $(this).attr("id")
    labelId = id.includes('country') ? '#'+ id + '-error' : '#seller_subscription_type-error'
    if ($(this).val() != '') {
      $(this).parents("div.form-group").removeClass('error-field');
      $(labelId).text('');
      $(labelId).css('display', 'd-none');
    } else {
      $(this).parents("div.form-group").addClass('error-field');
      labeltext = id.includes('country') ? "Country name is required" : "Subscription type is required"
      $(labelId).text(labeltext);
      $(labelId).css('display', 'block');
    }
	});
}
