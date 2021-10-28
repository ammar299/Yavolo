$(document).ready(function () {
  console.log("sellers js is loaded");
  sellerSearchByFilter();
  //Upload Sellers
  $(".upload-sellers-csv-btn").click(function () {
    $("#upload-sellers-csv-popup").modal("show");
  });

  $("#check-all-checkboxes").click(function () {
    if ($(this).is(":checked")) {
      $("input:checkbox").not(this).prop("checked", true);
    } else {
      $("input:checkbox").not(this).prop("checked", false);
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
    e.preventDefault();
    $sellerDropDown.text($(this).text());
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
