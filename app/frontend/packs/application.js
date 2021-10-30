// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

import JQuery from "jquery";
window.$ = window.jQuery = JQuery;

import "bootstrap";
import "@fortawesome/fontawesome-free/js/all";
import "../stylesheets/application.scss";

Rails.start();
ActiveStorage.start();
import "controllers";
require("jquery");
require("@nathanvda/cocoon");
require("packs/admin");
require("packs/categories");
require("packs/delivery_options");
require("packs/filter_groups");
require("packs/products");
require("packs/sellers");
require("packs/success-meter");
require("packs/date-picker");
require("packs/all-page-events");
require("@nathanvda/cocoon");
const ClassicEditor = require("@ckeditor/ckeditor5-build-classic");
require("packs/selectize.min");
require("packs/jquery.validate");
require("packs/additional-methods");
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
  // hide flash toasts
  $(document).on('click','.notice-cross-icon', function(){
    $(this).parent().fadeOut("slow");
  });
  // hide flash toasts
  $(document).on('click','.notice-cross-icon', function(){
    $(this).parent().fadeOut("slow");
  });
});
