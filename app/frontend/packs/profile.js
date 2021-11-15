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
      "seller[terms_and_conditions]": {
        required: "Please accept these Terms and conditions",
      },
    },
  });
  jQuery.validator.addMethod("url_without_scheme", function(value, element) {
        return /^(?:www\.)?[A-Za-z0-9_-]+\.+[A-Za-z0-9.\/%&=\?_:;-]+$/.test(value);
      }, "Please enter a valid URL without http/https"
  );

  jQuery.validator.addMethod("postal_code_uk", function (value, element) {
    return this.optional(element) || /^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$/.test(value);
  }, "Please specify a valid UK postal code");

  jQuery.validator.addMethod('phone_number_uk', function(value, element) {
        return this.optional(element) || value.length > 9 && value.match(/^(\(?(0|\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/);
      }, 'Please specify a valid UK phone number'
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
