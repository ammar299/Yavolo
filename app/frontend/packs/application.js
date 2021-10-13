// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

global.$ = jQuery;

import "bootstrap";
import "@fortawesome/fontawesome-free/js/all";
import "../stylesheets/application.scss";

Rails.start();
ActiveStorage.start();

import "controllers"
require("@nathanvda/cocoon")
require('packs/admin')
require('packs/categories')
require('packs/delivery_options')
require('packs/filter_groups')
require('packs/products')
require('packs/sellers')
require('packs/success-meter')
require("@nathanvda/cocoon")
require ("select_all.js")

$(function() {
  $("#selectAll").select_all();
});
