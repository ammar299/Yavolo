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
      "order[order_detail_attributes][name]": {
        required: true,
      },
      "order[order_detail_attributes][contact_number]": {
        required: true,
      },
      "order[billing_address_attributes][appartment]": {
        required: true,
      },
      "order[billing_address_attributes][postal_code]": {
        required: true,
        postal_code_uk: true,
      },
      "order[billing_address_attributes][address_line_1]": {
        required: true,
      },
      "order[billing_address_attributes][address_line_2]": {
        required: true,
      },
      "order[billing_address_attributes][city]": {
        required: true,
      },
      "order[billing_address_attributes][country]": {
        required: true,
      },
      billing_address_is_shipping_address: {},
      "order[shipping_address_attributes][appartment]": {
        requiredIfChecked: true,
      },
      "order[shipping_address_attributes][postal_code]": {
        requiredIfChecked: true,
        postal_code_uk: true,
      },
      "order[shipping_address_attributes][address_line_1]": {
        requiredIfChecked: true,
      },
      "order[shipping_address_attributes][address_line_2]": {
        requiredIfChecked: true,
      },
      "order[shipping_address_attributes][city]": {
        requiredIfChecked: true,
      },
      "order[shipping_address_attributes][country]": {
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
      "order[order_detail_attributes][name]": {
        required: "Name is required",
      },
      "order[order_detail_attributes][contact_number]": {
        required: "Contact number is required",
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
      "order[billing_address_attributes][country]": {
        required: "Country is required",
      },
      billing_address_is_shipping_address: {
        required: "Please accept these Terms and conditions",
      },
      "order[shipping_address_attributes][appartment]": {
        required: "Appratment is required",
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
      "order[shipping_address_attributes][country]": {
        required: "Country is required",
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
          value.match(/^(\(?(0|\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/))
      );
    },
    "Please specify a valid UK phone number"
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
      if (
        $("#billing_address_is_shipping_address").is(":checked") &&
        $.trim(val) == ""
      ) {
        return true;
      }
      return false;
    },
    "This field is required if checkbox is unchecked..."
  );
}
