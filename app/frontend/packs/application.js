// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

import JQuery from "jquery";
window.$ = window.jQuery = JQuery;
window.Rails = Rails;

import "bootstrap";
import "@fortawesome/fontawesome-free/js/all";
import "../stylesheets/application.scss";

Rails.start();
ActiveStorage.start();
import "controllers";
require("jquery");

require("@nathanvda/cocoon");
require("packs/jquery.inputmask.bundle.min");
require("packs/admin");
require("packs/categories");
require("packs/delivery_options");
require("packs/filter_groups");
require("packs/products");
require("packs/sellers");
require("packs/buyers");
require("packs/success-meter");
require("packs/orders");
require("packs/date-picker");
require("packs/all-page-events");
const ClassicEditor = require("@ckeditor/ckeditor5-build-classic");
require("packs/jquery.validate");
require("packs/selectize.min");
require("packs/additional-methods");
require("packs/profile");
require("packs/sign-up-steps");
require("packs/stripe");
require("packs/cart");
require("packs/slick.min");
require("packs/checkout");
require("packs/manual-bundles");
require("packs/google-pay");
require("packs/data-confirm-modal");
require("packs/import-csv.js");

$(document).ready(() => {
  $("body").on("focus", ".datepicker", function () {
    $(this)
      .datepicker({
        format: "dd/mm/yyyy",
        todayHighlight: true,
        defaultDate: new Date(),
        endDate: "-18y",
      })
      .on("changeDate", function (e) {
        // `e` here contains the extra attributes
      });
  });

  $("body").on("focus", ".datepicker-dashboard", function () {
    $(this)
      .datepicker({
        format: "dd/mm/yyyy",
        todayHighlight: true,
        defaultDate: new Date(),
      })
      .on("changeDate", function (e) {
        // `e` here contains the extra attributes
      });
  });
  // hide flash toasts
  $(document).on("click", ".notice-cross-icon", function () {
    $(this).parent().fadeOut("slow");
  });
  // hide flash toasts
  $(document).on("click", ".notice-cross-icon", function () {
    $(this).parent().fadeOut("slow");
  });

  // Disable changing number type field by scrolling
  $("input[type='number']").on("wheel", function () {
    return false;
  });
});

window.displayNoticeMessage = (message) => {
  message = `<div id="flash-msg">
    <p class="flash-toast notice notice-msg">
      ${message}
      <span  class="notice-cross-icon" aria-hidden="true">&times;</span>
    </p>
  </div>`;
  $("#flash-msg").html(message);
  setTimeout(function () {
    $("#flash-msg").find("p").remove();
  }, 3000);
  return message;
};

window.showButtonLoader = (button) => {
  $(button).prop("disabled",true)
  $(button).html($(button).text()+"<div class='ml-2 loadingio-spinner-rolling-x9emz9hqb6q'><div class='ldio-q57eiqc90zl'><div></div></div></div>")
}

window.hideButtonLoader = (button) => {
  $(button).prop("disabled",false)
  $(button).html($(button).text())
}

jQuery.validator.addMethod(
  "url_without_scheme",
  function (value, element) {
    return (
      this.optional(element) ||
      /^[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)$/.test(value)
    );
  },
  "Please enter a valid URL without http/https"
);

jQuery.validator.addMethod(
    "VAT_number_validation",
    function (value, element) {
        return (
            this.optional(element) ||
            /^GB(?:\d{3} ?\d{4} ?\d{2}(?:\d{3})?|[A-Z]{2}\d{3})$/.test(value)
        );
    },
    "Please enter a valid VAT number"
);

jQuery.validator.addMethod(
  "companies_house_registration",
  function (value, element) {
      return (
          this.optional(element) ||
          /^(?:([A-Z]\w|[0-9]{2})[0-9]{6})$/.test(value)
      );
  },
  "Please enter a valid House Registration Number (e.g AB123456, 99123456, C1234567)"
);

jQuery.validator.addMethod("validPrice", function(value) {
    let number = value.split('£')[value.split('£').length-1].split(',').join('')
    return Number(number) >= 0 && Number(number) <= 999999.99
}, "Please enter a valid price value.");

jQuery.validator.addMethod('productEan', function(value, element) {
    return this.optional(element) || /^(\d{13})?$/.test(value);
}, 'Please Enter a valid EAN');
import "controllers"
