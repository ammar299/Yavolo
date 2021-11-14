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
        },
      "seller[company_detail_attributes][doing_business_as]": {
        required: true,
      },
      "seller[company_detail_attributes][business_industry]": {
        required: true,
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
        required: true,
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
      },
      "seller[addresses_attributes][0][country]": {
        required: true,
      },
      "seller[addresses_attributes][0][phone_number]": {
        required: true,
      },
      "seller[business_representative_attributes][full_legal_name]": {
        required: true,
      },
      "seller[business_representative_attributes][email]": {
        required: true,
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
      },
      "seller[addresses_attributes][1][country]": {
        required: true,
      },
      "seller[addresses_attributes][1][phone_number]": {
        required: true,
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
      },
      "seller[bank_detail_attributes][account_number]": {
        required: true,
      },
      "seller[bank_detail_attributes][account_number_confirmation]": {
        required: true,
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
        required: "Name is required",
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
      "seller[company_detail_attributes][website_url]": {
        required: "Website URL is required",
      },
      "seller[company_detail_attributes][amazon_url]": {
        required: "Amazon URL is required",
      },
      "seller[company_detail_attributes][ebay_url]": {
        required: "ebay URL is required",
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
      },
      "seller[terms_and_conditions]": {
        required: "Please accept term & condtions",
      }
    },
  });
  jQuery.validator.addMethod("url_without_scheme", function(value, element) {
        return /^(?:www\.)?[A-Za-z0-9_-]+\.+[A-Za-z0-9.\/%&=\?_:;-]+$/.test(value);
      }, "Please enter a valid URL without http/https"
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
