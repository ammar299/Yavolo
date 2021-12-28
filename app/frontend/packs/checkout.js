$(document).ready(() => {
  console.log("checkout js is loaded");
  checkoutDetailsFormValidation();
});

function checkoutDetailsFormValidation() {
  $("form#checkout_details_form").validate({
    ignore: "",
    rules: {
      "order[order_detail_attributes][email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
      },
      "order[order_detail_attributes][first_name]": {
        required: true,
      },
      "order[order_detail_attributes][last_name]": {
        required: true,
      },
      "order[order_detail_attributes][phone_number]": {
        required: true,
        phone_number_uk: true
      },
      "order[shipping_address_attributes][appartment]": {
        required: true,
      },
      "order[shipping_address_attributes][postal_code]": {
        required: true,
        postal_code_uk: true,
      },
      "order[shipping_address_attributes][address_line_1]": {
        required: true,
      },
      "order[shipping_address_attributes][address_line_2]": {
        required: true,
      },
      "order[shipping_address_attributes][city]": {
        required: true,
      },
      "order[shipping_address_attributes][county]": {
        required: true,
      },
      billing_address_is_shipping_address: {},
      "order[billing_address_attributes][first_name]": {
        requiredIfChecked: true,
      },
      "order[billing_address_attributes][last_name]": {
        requiredIfChecked: true,
      },
      "order[billing_address_attributes][appartment]": {
        requiredIfChecked: true,
      },
      "order[billing_address_attributes][postal_code]": {
        requiredIfChecked: true,
        postal_code_uk: true,
      },
      "order[billing_address_attributes][address_line_1]": {
        requiredIfChecked: true,
      },
      "order[billing_address_attributes][address_line_2]": {
        requiredIfChecked: true,
      },
      "order[billing_address_attributes][city]": {
        requiredIfChecked: true,
      },
      "order[billing_address_attributes][county]": {
        requiredIfChecked: true,
      },
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      "order[order_detail_attributes][email]": {
        required: "Email is required",
      },
      "order[order_detail_attributes][first_name]": {
        required: "First Name is required",
      },
      "order[order_detail_attributes][last_name]": {
        required: "Last Name is required",
      },
      "order[order_detail_attributes][phone_number]": {
        required: "Contact number is required",
      },
      "order[shipping_address_attributes][appartment]": {
        required: "Apartment is required",
      },
      "order[shipping_address_attributes][postal_code]": {
        required: "Postal Code is required",
      },
      "order[shipping_address_attributes][address_line_1]": {
        required: "Address Line 1 is required",
      },
      "order[shipping_address_attributes][address_line_2]": {
        required: "Address Line 2 is required",
      },
      "order[shipping_address_attributes][city]": {
        required: "City is required",
      },
      "order[shipping_address_attributes][county]": {
        required: "County is required",
      },
      billing_address_is_shipping_address: {
        required: "Please accept these Terms and conditions",
      },
      "order[billing_address_attributes][first_name]": {
        required: "First Name is required",
      },
      "order[billing_address_attributes][last_name]": {
        required: "Last Name is required",
      },
      "order[billing_address_attributes][appartment]": {
        required: "Appratment is required",
      },
      "order[billing_address_attributes][postal_code]": {
        required: "Postal Code is required",
      },
      "order[billing_address_attributes][address_line_1]": {
        required: "Address Line 1 is required",
      },
      "order[billing_address_attributes][address_line_2]": {
        required: "Address Line 2 is required",
      },
      "order[billing_address_attributes][city]": {
        required: "City is required",
      },
      "order[billing_address_attributes][county]": {
        required: "County is required",
      },
    },
  });

  jQuery.validator.addMethod(
    "postal_code_uk",
    function (value, element) {
      return (
        this.optional(element) ||
        /^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$/.test(value)
      );
    },
    "Please specify a valid UK postal code"
  );

  jQuery.validator.addMethod(
    "phone_number_uk",
    function (value, element) {
      return (
        this.optional(element) ||
        (value.length > 9 &&
          value.match(/^(\(?(\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/))
      );
    },
    "Please specify a valid uk phone number (e.g +447911123456)"
  );
  jQuery.validator.addMethod(
    /* The value you can use inside the email object in the validator. */
    "regex",

    /* The function that tests a given string against a given regEx. */
    function (value, element, regexp) {
      /* Check if the value is truthy (avoid null.constructor) & if it's not a RegEx. (Edited: regex --> regexp)*/

      if (regexp && regexp.constructor != RegExp) {
        /* Create a new regular expression using the regex argument. */
        regexp = new RegExp(regexp);
      } else if (regexp.global) regexp.lastIndex = 0;

      /* Check whether the argument is global and, if so set its last index to 0. */

      /* Return whether the element is optional or the result of the validation. */
      return this.optional(element) || regexp.test(value);
    },
    "Please Enter a valid Email"
  );
  jQuery.validator.addMethod(
    "requiredIfChecked",
    function (val, ele, arg) {
      var is_checked = $('#billing_address_is_shipping_address').is(':checked')
      if ((is_checked === true) && ($.trim(val) === '')) {
        return true;
      }
      else if ((is_checked === true) && ($.trim(val) !== '')) {
        return true;
      }
      else if ((is_checked === false) && ($.trim(val) !== '')) {
        return true;
      }
      else if ((is_checked === false) && ($.trim(val) === '')) {
        return false;
      }
    },
    "This field is required if checkbox is unchecked."
  );
}
