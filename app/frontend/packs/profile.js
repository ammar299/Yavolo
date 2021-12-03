$(document).ready(function () {
  console.log("profile js is loaded");
  addNewSellerFormValidation();
  newSellerFormDropdownValidation();
});
function addNewSellerFormValidation() {
  $("form#add_new_seller_profile_form").validate({
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
      "seller[terms_and_conditions]": {
        required: true,
      },
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
      "seller[terms_and_conditions]": {
        required: "Please accept these Terms and conditions",
      },
    },
  });

  jQuery.validator.addMethod("postal_code_uk", function (value, element) {
    return this.optional(element) || /^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$/.test(value);
  }, "Please specify a valid UK postal code");

  jQuery.validator.addMethod('phone_number_uk', function(value, element) {
        return this.optional(element) || value.length > 9 && value.match(/^(\(?(\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/);
      }, 'Please specify a valid UK phone number(e.g +447911123456)'
  );
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
      },'Please Enter a valid Email'
  );
}

function newSellerFormDropdownValidation() {
  $("body").on(
    "change",
    "#seller_company_detail_attributes_country, #seller_addresses_attributes_0_country, #seller_addresses_attributes_1_country",
    "#seller_subscription_type",
    function () {
      labelId = $(this).is("#seller_company_detail_attributes_country")
        ? "#seller_company_detail_attributes_country-error"
        : $(this).is("#seller_addresses_attributes_0_country")
        ? "#seller_addresses_attributes_0_country-error"
        : $(this).is("#seller_addresses_attributes_1_country")
        ? "#seller_addresses_attributes_1_country-error"
        : "#seller_subscription_type-error";
      if ($(this).val() != "") {
        $(this).parents("div.form-group").removeClass("error-field");
        $(labelId).text("");
        $(labelId).css("display", "d-none");
      } else {
        $(this).parents("div.form-group").addClass("error-field");
        labeltext = $(this).is("#seller_company_detail_attributes_country")
          ? "Country name is required"
          : $(this).is("#seller_addresses_attributes_0_country")
          ? "Country name is required"
          : $(this).is("#seller_addresses_attributes_1_country")
          ? "Country name is required"
          : "Subscription type is required";
        $(labelId).text(labeltext);
        $(labelId).css("display", "block");
      }
    }
  );

  // $("body").on(
  //   "click",
  //   "input[name='seller[terms_and_conditions]']",
  //   function () {
  //     labelId = "#seller_terms_and_conditions-error";
  //     if ($(this).prop("checked") == false) {
  //       $(this).parents("div.form-check").addClass("error-field");
  //       labeltext = "Please accept these terms and conditions";
  //       $(labelId).text(labeltext);
  //       $(labelId).css("display", "block");
  //     } else {
  //       $(this).parents("div.form-check").addClass("error-field");
  //       $(labelId).text("");
  //       $(labelId).css("display", "d-none");
  //     }
  //   }
  // );

  // $("body").on(
  //   "change",
  //   "input[name='seller[recieve_deals_via_email]']",
  //   function () {
  //     labelId = "#seller_recieve_deals_via_email";
  //     if ($(this).prop("checked", false)) {
  //       $(this).parents("div.form-group").addClass("error-field");
  //       labeltext = "Please accept deals via email";
  //       $(labelId).text(labeltext);
  //       $(labelId).css("display", "block");
  //     } else {
  //       $(this).parents("div.form-group").addClass("error-field");
  //       $(labelId).text("");
  //       $(labelId).css("display", "d-none");
  //     }
  //   }
  // );
}
