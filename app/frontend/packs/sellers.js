$(document).ready(function () {
  onBoardingApiScript();
  sellerExportOrder();
  sellerOnBoarding();
  // sellerSearchByFilter();
  addNewSellerFormValidation();
  newSellerFormDropdownValidation();
  validateEligibility();
  loginSettingsForm();
  validateSellerSignInSignUp();
  validateSellerSignIn();
  TwoFactorAuthEmail();
  TwoFactorAuthForCode();
  sellerTimeOutSlector();
  setSellerOrderSearchMenuAndQueryName();
  bindAndSortByEvent();
  bindRemoveFilterBy();
  endSubscriptionHanlder();
  sellerLoginSettingsForm();
  emailErrorRemovedBaackend();
  $(".upload-sellers-csv-btn").click(function () {
    $("#upload-sellers-csv-popup").modal("show");
  });
  bindReasonUpdateOnInput();
  bindSellerCsvPopup();
  

  uploadCsvDragDrop();
  function addNewSellerFormValidation() {
    $("form#add_new_seller_form").validate({
      ignore: "",
      rules: {
        "seller[first_name]": {
          required: true,
        },
        "seller[last_name]": {
          required: true,
        },
        "seller[email]": {
          required: true,
          email: true,
          regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
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
        "seller[company_detail_attributes][vat_number]": {
          required: true,
          VAT_number_validation: true,
        },
        "seller[company_detail_attributes][website_url]": {
          url_without_scheme: true,
        },
        "seller[company_detail_attributes][amazon_url]": {
          url_without_scheme: true,
        },
        "seller[company_detail_attributes][ebay_url]": {
          url_without_scheme: true,
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
          postal_code_uk: true,
        },
        "seller[addresses_attributes][0][country]": {
          required: true,
        },
        "seller[addresses_attributes][0][phone_number]": {
          required: true,
          phone_number_uk: true,
          noSpace: true,
        },
        "seller[business_representative_attributes][full_legal_name]": {
          required: true,
        },
        "seller[business_representative_attributes][email]": {
          required: true,
          email: true,
          regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
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
          postal_code_uk: true,
        },
        "seller[addresses_attributes][1][country]": {
          required: true,
        },
        "seller[addresses_attributes][1][phone_number]": {
          required: true,
          phone_number_uk: true,
          noSpace: true,
        },
        "seller[subscription_type]": {
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
        "seller[first_name]": {
          required: "Required",
        },
        "seller[last_name]": {
          required: "Required",
        },
        "seller[email]": {
          required: "Required",
        },
        "seller[company_detail_attributes][name]": {
          required: "Required",
        },
        "seller[company_detail_attributes][country]": {
          required: "Required",
        },
        "seller[company_detail_attributes][legal_business_name]": {
          required: "Required",
        },
        "seller[company_detail_attributes][companies_house_registration_number]":
          {
            required: "Required",
          },
        "seller[company_detail_attributes][doing_business_as]": {
          required: "Required",
        },
        "seller[company_detail_attributes][business_industry]": {
          required: "Required",
        },
        "seller[company_detail_attributes][vat_number]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][address_line_1]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][address_line_2]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][city]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][county]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][postal_code]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][country]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][phone_number]": {
          required: "Required",
        },
        "seller[business_representative_attributes][full_legal_name]": {
          required: "Required",
        },
        "seller[business_representative_attributes][email]": {
          required: "Required",
        },
        "seller[business_representative_attributes][job_title]": {
          required: "Required",
        },
        "seller[business_representative_attributes][date_of_birth]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][address_line_1]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][address_line_2]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][city]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][county]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][postal_code]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][country]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][phone_number]": {
          required: "Required",
        },
        "seller[subscription_type]": {
          required: "Required",
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
      "Enter valid UK postal code"
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
      "Enter valid UK phone number(e.g +447911123456)"
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
      }
    );
  }

  function loginSettingsForm() {
    $("form#add_new_seller_profile_form").validate({
      ignore: "",
      rules: {
        "seller[company_detail_attributes][first_name]": {
          required: true,
        },
        "seller[company_detail_attributes][last_name]": {
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
            companies_house_registration: true
          },
        "seller[company_detail_attributes][doing_business_as]": {
          required: true,
        },
        "seller[company_detail_attributes][business_industry]": {
          required: true,
        },
        "seller[company_detail_attributes][website_url]": {
          url_without_scheme: true,
        },
        "seller[company_detail_attributes][amazon_url]": {
          url_without_scheme: true,
        },
        "seller[company_detail_attributes][ebay_url]": {
          url_without_scheme: true,
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
          postal_code_uk: true,
        },
        "seller[addresses_attributes][0][country]": {
          required: true,
        },
        "seller[addresses_attributes][0][phone_number]": {
          required: true,
          phone_number_uk: true,
          noSpace: true,
        },
        "seller[business_representative_attributes][full_legal_name]": {
          required: true,
        },
        "seller[business_representative_attributes][email]": {
          required: true,
          email: true,
          regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
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
          postal_code_uk: true,
        },
        "seller[addresses_attributes][1][country]": {
          required: true,
        },
        "seller[addresses_attributes][1][phone_number]": {
          required: true,
          phone_number_uk: true,
          noSpace: true,
        },
      },
      highlight: function (element) {
        $(element).parents("div.form-group").addClass("error-field");
      },
      unhighlight: function (element) {
        $(element).parents("div.form-group").removeClass("error-field");
      },
      messages: {
        "seller[company_detail_attributes][first_name]": {
          required: 'Required',
        },
        "seller[company_detail_attributes][last_name]": {
          required: 'Required',
        },
        "seller[company_detail_attributes][name]": {
          required: "Required",
        },
        "seller[company_detail_attributes][country]": {
          required: "Required",
        },
        "seller[company_detail_attributes][legal_business_name]": {
          required: "Required",
        },
        "seller[company_detail_attributes][companies_house_registration_number]":
          {
            required: "Required",
          },
        "seller[company_detail_attributes][doing_business_as]": {
          required: "Required",
        },
        "seller[company_detail_attributes][business_industry]": {
          required: "Required",
        },
        "seller[company_detail_attributes][vat_number]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][address_line_1]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][address_line_2]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][city]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][county]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][postal_code]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][country]": {
          required: "Required",
        },
        "seller[addresses_attributes][0][phone_number]": {
          required: "Required",
        },
        "seller[business_representative_attributes][full_legal_name]": {
          required: "Required",
        },
        "seller[business_representative_attributes][email]": {
          required: "Required",
        },
        "seller[business_representative_attributes][job_title]": {
          required: "Required",
        },
        "seller[business_representative_attributes][date_of_birth]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][address_line_1]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][address_line_2]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][city]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][county]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][postal_code]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][country]": {
          required: "Required",
        },
        "seller[addresses_attributes][1][phone_number]": {
          required: "Required",
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
      "Enter valid UK postal code"
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
      "Enter valid UK phone number(e.g +447911123456)"
    );

    jQuery.validator.addMethod("noSpace", function(value, element) { 
      return value.indexOf(" ") < 0 && value != ""; 
    }, "No space please");

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
      }
    );
  }

  function sellerLoginSettingsForm() {
    $("form#seller_profile_login_setting_form").validate({
      ignore: "",
      rules: {
        "seller[recovery_email]": {
          email: true,
          regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
        },
        "seller[contact_number]": {
          phone_number_uk: true,
          noSpace: true,
        },
        "seller[password]": {
          required: function(element){
            return $("#seller_current_password").val().length > 0;
          },
        },
        "seller[password_confirmation]":
        {
          required: function(element){
            return $("#seller_current_password").val().length > 0;
          },
          equalTo: "#seller_password"
        },
      },
      highlight: function (element) {
        $(element).parents("div.form-group").addClass("error-field");
      },
      unhighlight: function (element) {
        $(element).parents("div.form-group").removeClass("error-field");
      },
      messages: {
        "seller[password]": {
          required: "New password required",
        },
        "seller[password_confirmation]":
        {
          required: "New password required",
          equalTo: "New password does not match"
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
      "Enter valid UK postal code"
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
      "Enter valid UK phone number(e.g +447911123456)"
    );

    jQuery.validator.addMethod("noSpace", function(value, element) { 
      return value.indexOf(" ") < 0 && value != ""; 
    }, "No space please");

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
      }
    );
  }

  $("#check-all-checkboxes").click(function () {
    if ($(this).is(":checked")) {
      $("input:checkbox").not(this).prop("checked", true);
    } else {
      $("input:checkbox").not(this).prop("checked", false);
    }
  });

  $("#check-all-checkboxes").click(function () {
    if ($(this).is(":checked")) {
      $("input:checkbox").not(this).prop("checked", true);
    } else {
      $("input:checkbox").not(this).prop("checked", false);
    }
  });

  $(".multiple-products input").click(function () {
    if (!$(this).is(":checked")) {
      $("#check-all-checkboxes").prop("checked", false);
      $('.mark-bulk-update').prop('checked', false);
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
  
  $(document).on("click", ".add-card", function (e) {
    e.preventDefault();
    $("#stripe-card-submit").prop("disabled", false);
    stripeLoad();
  });

  $(document).on("click", ".card-delete", function (e) {
    e.preventDefault();
    $("#membership-card-remove").attr("data", $(this).attr("name"));
    $("#membership-card-remove-confirm").modal("show");
  });

  $(document).on("click", "#membership-card-remove", function (e) {
    e.preventDefault();
    let url = $(this).attr("data");
    $.ajax({
      url: url,
      type: "DELETE",
    });
  });

  $(".modal").on("hide.bs.modal", function () {
    $("div").removeClass("modal-backdrop");
  });

  $(document).on("click", ".set-default", function (e) {
    e.preventDefault();
    $("#membership-card-set-default").attr("data", $(this).attr("name"));
    $("#membership-card-set-default-confirm").modal("show");
  });

  $(document).on("click", "#membership-card-set-default", function (e) {
    e.preventDefault();
    let url = $(this).attr("data");
    $("#membership-card-set-default-confirm").modal("hide");
    $.ajax({
      url: url,
      type: "GET",
    });
  });

  $(document).on("click", "#verify-requirments", function (e) {
    e.preventDefault();
    $.ajax({
      url: "/sellers/refresh_onboarding_link",
      type: "get",
      success: function (response) {
        if (response.link) {
          // window.open(response.link, "_blank");
          window.location = response.link;
        }
      },
      error: function () {
        displayNoticeMessage("Link Not Found.");
      },
    });
  });

  $(document).on("click", ".payout-bank-account-remove", function (e) {
    e.preventDefault();
    $("#stripe-payout-bank-account-end").attr("data", $(this).attr("name"));
    $("#stripe-payout-bank-account-confirm").modal("show");
  });

  $(document).on("click", "#stripe-payout-bank-account-end", function (e) {
    e.preventDefault();
    let seller = $(this).attr("data");
    $.ajax({
      url: "/sellers/remove_payout_bank_account",
      type: "DELETE",
      data: { seller: seller },
    });
  });

  $(document).on("click", ".submit-bank-account", function (e) {
    e.preventDefault();
    let form = $("#bank-account-verification-form").serialize();
    $("#bank-account-card-errors").html("");
    $(this).prop("disabled", true);
    $.ajax({
      type: "POST",
      url: "/sellers/add_bank_details",
      data: form,
      success: function (response) {
        if (response.result) {
          window.location = response.link;
        }
        if (response.errors) {
          for (let i = 0; i < response.errors.length; i++) {
            $("#bank-account-card-errors").append(
              "<li>" + response.errors[i] + "</li>"
            );
          }
          $(".submit-bank-account").prop("disabled", false);
        } else {
        }
      },
      error: function (error) {
        $(".submit-bank-account").prop("disabled", false);
      },
    });
  });

  $(".seller-export-csv-selected-products").click(function (event) {
    var selected_products = [];
    $(".multiple-products input[type=checkbox]:checked").each(function () {
      selected_products.push($(this).val());
    });
    if (selected_products.length < 1) {
      $(".multiple-products input[type=checkbox]").each(function () {
        selected_products.push($(this).val());
      });
      $(this).attr("href","/sellers/products/export_csv.csv?products=" + selected_products);
    } else {
      $(this).attr("href","/sellers/products/export_csv.csv?products=" + selected_products);
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
      $("#csv_import_sellers_file").attr("disabled", false);
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
    $(".seller-listing-filters a").removeClass("active");
    $(this).addClass("active");
    e.preventDefault();
    $sellerDropDown.text($(this).text());
    $sellerDropDown.append(
      '<i class="fa fa-angle-down ml-4" aria-hidden="true"></i>'
    );
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

function sellerOnBoarding() {
  let searchParams = new URLSearchParams(window.location.search);
  if (searchParams.has("merchantId") == true) {
    let merchantId = searchParams.get("merchantId");
    let merchantIdInPayPal = searchParams.get("merchantIdInPayPal");
    let consentStatus = searchParams.get("consentStatus");
    let productIntentId = searchParams.get("productIntentId");
    let isEmailConfirmed = searchParams.get("isEmailConfirmed");
    // console.log("params=>",merchantId,"   ",merchantIdInPayPal)
    let host_url = process.env.DEFAULT_HOST_URL;
    $.ajax({
      url: "/sellers/check_onboarding_status",
      type: "POST",
      data: { merchantId: merchantId, merchantIdInPayPal: merchantIdInPayPal },
      success: function (response) {
        notify(response, host_url);
      },
      error: function () {
        $("#paypal-integration-failure").addClass("notice-msg");
      },
    });
  }
}

function onBoardingApiScript() {
  (function (d, s, id) {
    var js,
      ref = d.getElementsByTagName(s)[0];
    if (!d.getElementById(id)) {
      js = d.createElement(s);
      js.id = id;
      js.async = true;
      js.src =
        "https://www.paypal.com/webapps/merchantboarding/js/lib/lightbox/partner.js";
      ref.parentNode.insertBefore(js, ref);
    }
  })(document, "script", "paypal-js");
  $(".CardField--ltr").css("top", "3px");
}

function notify(response, host_url) {
  if (response.status == true) {
    $("#paypal-integration-success").addClass("notice-msg");
    setTimeout(function () {
      $("#paypal-integration-success").removeClass("notice-msg");
      window.location.href = "https://" + host_url + "/sellers";
    }, 3000);
  } else {
    $("#paypal-integration-failure").addClass("notice-msg");
  }
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
}

window.validateSellerEditForm = function () {
  $("form#admin-sellers-update-form").validate({
    ignore: "",
    rules: {
      "seller[email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
      },
      "seller[company_detail_attributes][first_name]": {
        required: true,
      },
      "seller[company_detail_attributes][last_name]": {
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
          companies_house_registration: true
        },
      "seller[company_detail_attributes][doing_business_as]": {
        required: true,
      },
      "seller[company_detail_attributes][business_industry]": {
        required: true,
      },
      "seller[company_detail_attributes][website_url]": {
        url_without_scheme: true,
      },
      "seller[company_detail_attributes][amazon_url]": {
        url_without_scheme: true,
      },
      "seller[company_detail_attributes][ebay_url]": {
        url_without_scheme: true,
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
        postal_code_uk: true,
      },
      "seller[addresses_attributes][0][country]": {
        required: true,
      },
      "seller[addresses_attributes][0][phone_number]": {
        required: true,
        noSpace: true,
        phone_number_uk: true,
      },
      "seller[business_representative_attributes][full_legal_name]": {
        required: true,
      },
      "seller[business_representative_attributes][email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
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
        postal_code_uk: true,
      },
      "seller[addresses_attributes][1][country]": {
        required: true,
      },
      "seller[addresses_attributes][1][phone_number]": {
        required: true,
        phone_number_uk: true,
        noSpace: true,
      },
      "seller[subscription_type]": {
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
      "seller[company_detail_attributes][first_name]": {
        required: "First name is required",
      },
      "seller[company_detail_attributes][last_name]": {
        required: "Last name is required",
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
    "Enter valid UK postal code"
  );

  jQuery.validator.addMethod(
    "exactlength",
    function (value, element, param) {
      return this.optional(element) || value.length == param;
    },
    $.validator.format("Enter exactly {0} characters.")
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
    "Enter valid UK phone number(e.g +447911123456)"
  );

  jQuery.validator.addMethod("noSpace", function(value, element) { 
    return value.indexOf(" ") < 0 && value != ""; 
  }, "No space please");

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
    "Enter a valid Email"
  );
};

function validateSellerSignInSignUp() {
  $("form#new_seller").validate({
    rules: {
      "seller[first_name]": {
        required: true,
      },
      "seller[last_name]": {
        required: true,
      },
      "seller[email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
      },
      "seller[password]": {
        required: true,
      },
      "seller[password_confirmation]": {
        required: true,
        equalTo: "#seller_password",
      },
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      "seller[first_name]": {
        required: "First name is required",
      },
      "seller[last_name]": {
        required: "Last name is required",
      },
      "seller[email]": {
        required: "Email is required",
      },
      "seller[password]": {
        required: "Password is required",
      },
      "seller[password_confirmation]": {
        required: "Password confirmation is required",
        equalTo: "Password does not match",
      },
    },
  });
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
    "Please enter a valid email address."
  );
}

function validateSellerSignIn() {
  $("form#seller-sign-in").validate({
    rules: {
      "seller[email]": {
        required: true,
        remote: function(){
          var checkit = {
            type: "get",
            url:  "/check_valid_email"
            // data : 'email=' + email,
          };
          return checkit;
        }
      },
      "seller[password]": {
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
        remote: "Email does not exist"
      },
      "seller[password]": {
        required: "Password is required",
      },
    },
  });
}

function sellerTimeOutSlector() {
  $("body").on("click", ".time-out-session", function () {
    $("#seller_timeout").val().length > 1;
    if ($(this).is(":checked")) {
      if($('#seller-timeout-filed').val().length<1){
        $('#seller-timeout-filed').val('After 1 hour of no activity')
      }
      $(".logout-time-dropdown").removeClass("d-none");
      $('#seller-timeout-filed').removeAttr('disabled')
      // $(".seller-selector").show()
    } else {
      $(".logout-time-dropdown").addClass("d-none");
      // $(".seller-selector").hide()
      $(".selector-value").val("");
      $('#seller-timeout-filed').attr('disabled', true)
    }
  });
}

function validateEligibility() {
  $("body").on("click", ".not-eligible-toast", function () {
    $("#flash-msg").find("p").remove();
    var toast =
      '<p class="flash-toast notice notice-msg">Please complete your dashboard required steps! <span  class="notice-cross-icon" aria-hidden="true">&times;</span> </p>';
    $("#flash-msg").html(toast);
    setTimeout(function () {
      $("#flash-msg").find("p").remove();
    }, 3000);
  });
}

function uploadCsvDragDrop() {
  if (document.getElementById("upload-sellers-csv-popup"))
    bindDragAndDropEvents("upload-sellers-csv-popup");
}

function bindDragAndDropEvents(dropAreaId) {
  let dropArea = document.getElementById(dropAreaId);
  ["dragenter", "dragover", "dragleave", "drop"].forEach((eventName) => {
    dropArea.addEventListener(eventName, preventDefaults, false);
  });
  dropArea.addEventListener("drop", fileDropHandler, false);
}

function fileDropHandler(e) {
  let dt = e.dataTransfer;
  let files = dt.files;
  let fileValidator = validCsvFile(files);
  if (fileValidator.isValid) {
    $("#upload-sellers-csv-popup .modal-body").find(".file-errors").remove();
    uploadCSVFile(files);
  } else {
    $("#upload-sellers-csv-popup.modal-body").find(".file-errors").remove();
    $("#upload-sellers-csv-popup .modal-body").append(
      '<ul class="file-errors" style="color: red;">' +
        fileValidator.errors.map((e) => "<li>" + e + "</li>").join("") +
        "</ul>"
    );
  }
}

function preventDefaults(e) {
  e.preventDefault();
  e.stopPropagation();
}

function TwoFactorAuthEmail() {
  $("form#two-factor-email").validate({
    ignore: "",
    rules: {
      email: {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
      },
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      email: {
        required: "Required",
      },
    },
  });
}

function TwoFactorAuthForCode() {
  $("form#two-auth-code").validate({
    ignore: "",
    rules: {
      otp_attempt: {
        required: true,
        exactlength: 6,
      },
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      otp_attempt: {
        required: "Required",
      },
    },
  });
}

window.reviewedLoginScreen = function(seller) {
  if (!seller?.reviewed_login_screen) {
    $.ajax({
      type: "GET",
      url: "/sellers/profiles/1/reviewed_login_screen",
    });
  }
}

function stripeLoad() {
  var stripe = Stripe('pk_test_51IfjFUFqSiWsjxhXbRrObdGnNbi0HGp64DKuqsivFjJN81Dip3ZpRAFUKGrOxhZkAoRZMbEOSLr7SAvvk6bmDvTu00eJrWMQB2');
  var elements = stripe.elements();

  var style = {
    base: {
      // Add your base input styles here. For example:
      fontSize: "14px",
      color: "#640529",
      padding: "1em",
    },
    invalid: {
      iconColor: "red",
      color: "red",
    },
  };

  // Create an instance of the card Element.
  var card = elements.create("card", { style: style });
  // Add an instance of the card Element into the `card-element` <div>.
  card.mount("#card-element");

  var form = document.getElementById("payment-form");
  form.addEventListener("submit", function (event) {
    $("#stripe-card-submit").prop("disabled", true);
    event.preventDefault();
    stripe.createToken(card).then(function (result) {
      if (result.error) {
        // Inform the customer that there was an error.
        $("#stripe-card-submit").prop("disabled", false);
        var errorElement = document.getElementById("card-errors");
        errorElement.textContent = result.error.message;
      } else {
        // Send the token to your server.
        stripeTokenHandler(result.token);
      }
    });
  });
}

function stripeTokenHandler(token) {
  // Insert the token ID into the form so it gets submitted to the server
  var form = document.getElementById("payment-form");
  var hiddenInput = document.createElement("input");
  hiddenInput.setAttribute("type", "hidden");
  hiddenInput.setAttribute("name", "stripeToken");
  hiddenInput.setAttribute("value", token.id);
  form.appendChild(hiddenInput);
  var dataString = $("#payment-form").serialize();
  $.ajax({
    type: "POST",
    url: "/sellers/payment_methods",
    data: dataString,
  });
  // Submit the form
  // form.submit();
}

function setSellerOrderSearchMenuAndQueryName() {
  $('.seller-orders-filters a').click(function (e) {
    e.preventDefault();
    let currentFilter = $(this).text().trim();
    $('.seller-orders-filters a').removeClass('active');
    $(this).addClass('active');
    $('.current-order-search-filter').html(currentFilter + ' <i class="fa fa-angle-down ml-2" aria-hidden="true"></i>');
    switch (currentFilter) {
      case 'Product Title':
        parsingSearchParams("Product Title", 'line_items_product_title_cont');
        break;
      case 'Order Number':
        parsingSearchParams("Order Number", 'order_number_cont');
        break;
      case 'Customer Name':
        parsingSearchParams('Customer Name', 'order_detail_full_name_cont');
        break;
      case 'Customer Postcode':
        parsingSearchParams('Customer Postcode', 'shipping_address_postal_code_or_billing_address_postal_code_cont');
        break;
      case 'SKU':
        parsingSearchParams('SKU', 'line_items_product_sku_cont');
        break;
      case 'YAN':
        parsingSearchParams('YAN', 'line_items_product_yan_cont');
        break;
      case 'EAN':
        parsingSearchParams('EAN', 'line_items_product_ean_cont');
        break;
      default:
        $('.current-search-filter').text('Search All');
        parsingSearchParams('Search All', 'line_items_product_title_or_order_detail_full_name_or_shipping_address_postal_code_or_billing_address_postal_code_or_line_items_product_sku_or_line_items_product_yan_or_line_items_product_ean_or_order_number_cont');
        break;
    }
  });
}

function parsingSearchParams(search_title, search_type) {
  let searchField = $(".seller-order-search-field");
  let filterType = $("#seller-order-filter-type");
  searchField.attr('name', 'q[' + search_type + ']');
  $('#csfn').val(search_type);
  filterType.val(search_title);
}

function bindAndSortByEvent() {
  $('.sortby-seller-orders').click(function (e) {
    e.preventDefault();
    if ($('#q_s').length === 0) {
      $('#seller_order_search').append('<input type="hidden" name="q[s]" id="q_s">')
      $("#q_s").val($(this).data('sortby'));
    }
    assignValueToSellerOrderSortFilterInput($(this).data('sortby'))
    $('form#seller_order_search').submit();
  });
}

function assignValueToSellerOrderSortFilterInput(currentValue) {
  const id_asc = "id asc";
  const id_desc = "id desc";
  const price_asc = "sub_total asc";
  const price_desc = "sub_total desc";
  const inputVal = $("#q_s").val();
  let valueArray = []

  try {valueArray = JSON.parse(inputVal.split(","))} catch (e) {}

  if (currentValue === price_desc && valueArray.includes(price_asc)) {
    valueArray = valueArray.filter(i => i !== price_asc || i.strip == "")
  } else if (currentValue === price_asc && valueArray.includes(price_desc)) {
    valueArray = valueArray.filter(i => i !== price_desc || i.strip == "")
  } else if (currentValue === id_desc && valueArray.includes(id_asc)) {
    valueArray = valueArray.filter(i => i !== id_asc || i.strip == "")
  } else if (currentValue === id_asc && valueArray.includes(id_desc)) {
    valueArray = valueArray.filter(i => i !== id_desc || i.strip == "")
  }
  valueArray.push(currentValue);
  $("#q_s").val(JSON.stringify(valueArray));
}

function bindRemoveFilterBy(){
  $(document).on('click','.rm-filterby',function(){
    let removedFilter = $(this).data('yfilter');
    bindRemoveFilterBySortOrderForOrder(removedFilter);
    $('form#seller_order_search').submit();
  });
}

function bindRemoveFilterBySortOrderForOrder(removedFilter) {
  const inputVal = $('#q_s').val()
  let valueArray = []
  try {valueArray = JSON.parse(inputVal.split(","))} catch (e) {}
  valueArray = valueArray.filter(i=> i !== removedFilter)
  $('#q_s').val(JSON.stringify(valueArray));
}

function endSubscriptionHanlder(){
  initialDecisionModule()
  reasonModule()
}

function initialDecisionModule(){
  $(document).on("click", ".end-subscription", function (e) {
    e.preventDefault();
    $("#stripe-subscription-end").attr("data", $(this).attr("name"));
    $("#stripe-subscription-end-confirm").modal("show");
  });

}

function reasonModule(){
  reasonSelection()
  $(document).on("click", ".end-subscription-link", function (e) {
    e.preventDefault();
    $("#stripe-subscription-end-confirm").modal("hide");
    $("#stripe-subscription-end-reason-confirm").modal("show");
  });

  $(document).on("click", ".end-subscription-link", function (e) {
    e.preventDefault();
    $("#stripe-subscription-end-confirm").modal("hide");
    $("#stripe-subscription-end-reason-confirm").modal("show");
  });

  $(document).on("click", "#stripe-subscription-reason-end", function (e) {
    e.preventDefault();
    let url = $(this).attr("data");
    let reason = $(".append-reason").text()
    if (reason == "Other"){
      reason = $(".reason-input-field").val()
      if (reason == "")
      {
        displayNoticeMessage("Reason is required")
        $("#dropdownMenuLinkForEndSubscription")[0].click()
        return false
      }
      unsubscribeSeller(url,reason)
    }
    else{
      unsubscribeSeller(url,reason)
    }

  });

}

function unsubscribeSeller(url,reason){
  $.ajax({
    url: url,
    type: "get",
    data: {reason: reason},
  });
}

function reasonSelection(){
  // $(".select-reason:first-child").find(".fa-check").removeClass("invisible") will be used later
  $(".select-reason:nth-child(2)").addClass("active-sub")
  hideShow("hide")
  $(document).on("click", ".select-reason", function (e) {
    e.preventDefault();
    $(".select-reason").each(function() {
      $(this).removeClass("active-sub")
    });
    
    $(".append-reason").html($(this).text())
    $(this).addClass("active-sub")
    hideShow("hide")
    if ($(this).text() == "Other"){
      hideShow("show")
      return false
    }
      
  });

}

function hideShow(action){
  if (action == "hide"){
    $(".reason-label").addClass("d-none")
    $(".other-reason").addClass("d-none")
    $(".reason-input").addClass("d-none")
  }else{
    $(".reason-label").removeClass("d-none")
    $(".other-reason").removeClass("d-none")
    $(".reason-input").removeClass("d-none")
  }
  
}

function bindReasonUpdateOnInput(){
  $(document).on("input", ".reason-input-field", function (e) {
    $(".other-reason").html($(".reason-input-field").val())
  })
}

function eanErrorRemoveBackend(){
  $(".ean-product-field").on('input',function(){
    if($(this).parent().find('.form-text')[0])
     $(this).parent().find('.form-text')[0].remove()
 })
}

function emailErrorRemovedBaackend(){
  $(".seller-email-field").on('input',function(){
    if($(this).parent().find('.form-text')[0])
     $(this).parent().find('.form-text')[0].remove()
 })
}

// TODO: bindSellerCsvPopup function is using two times here
function bindSellerCsvPopup(){
  $(".upload-sellers-csv-btn").click(function () {
    $("#upload-sellers-csv-popup").modal("show");
  });
}

function sellerExportOrder() {
  $(".seller-orders-export").click(function (event) {
    var selected_orders = []
    $('.multiple-orders input[type=checkbox]:checked').each(function () {
      selected_orders.push($(this).val())
    });
    if (selected_orders.length < 1) {
      $('.multiple-orders input[type=checkbox]').each(function () {
        selected_orders.push($(this).val())
      });
      $(this).attr('href', '/sellers/orders/export_orders.csv?orders=' + selected_orders);
    } else {
      $(this).attr('href', '/sellers/orders/export_orders.csv?orders=' + selected_orders);
    }
  })
}

