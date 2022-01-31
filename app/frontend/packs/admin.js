// load all admin related js or import admin controllers js
$(document).ready(function(){
  console.log('Admin Js is loaded')
  $('.back-btn-action').click(function(){
    window.history.back();
  });
  validateAdminSignIn()
  validateChangePasswordForm()
  validateResetPasswordForm()
  adminManageSubscription()
  cardRemoveHandler()
  renewSubscriptionHandler()
  removePayoutBankAccountHandler()
  contactSellerPopup()
  createDeleteSubscription()
  validatePlanForm()
  validateContactUsForm()
  checkPlanFormValidation()
  // showButtonLoader("#create-subscription-form-submit") pass id to show loader in button
  // hideButtonLoader("#create-subscription-form-submit") pass id to hide loader in button
  calculateRefund();
  sumOfTotalPaid();
  calculateSalesCommission();
  // verifyBankAccountForPayoutHanlder()
  
  $(document).on("click", "#stripe-subscription-cancel-by-admin", function(e){
    let seller = $(this).attr("data")
    let url = "/admin/sellers/"+seller+"/update_subscription_by_admin?id="+seller
    let selectedValue = $(".confirmation-text").attr("name")
    $('#stripe-subscription-end-by-admin-confirm').modal('hide');
    $.ajax({
      url: url,
      type: "POST",
      data: {subsciption_status: selectedValue},
    });
  })
 
});

$(document).ready(function(){
  toggleDashboardMenu();
    var hasClass = false;
    $(".parent").click(function(){
      var $ul = $(this).find('ul');
      if($(this).hasClass('active')){
        $(this).removeClass('active');
        $ul.addClass('d-none');
      }
      else {
        $(this).addClass('active');
        $ul.removeClass('d-none');
      }
    });
   
    $(document).on("click", ".export-csv-selected-sellers", function(e){
      var selected_sellers = []
      $('.multiple-update-sellers input[type=checkbox]:checked').each(function () {
      selected_sellers.push($(this).val())
      });

      if (selected_sellers.length < 1) {
        $(this).attr('href','/admin/export_sellers.csv?sellers='+selected_sellers+'&all=true')
      }
      else{
        $(this).attr('href','/admin/export_sellers.csv?sellers='+selected_sellers+'&all=false')
      }
    })

    $(".admin-export-csv-selected-products").click(function(event){
      var selected_products = []
      $('.multiple-products input[type=checkbox]:checked').each(function () {
      selected_products.push($(this).val())
      });
      if (selected_products.length < 1) {
          $('.multiple-products input[type=checkbox]').each(function() {
            selected_products.push($(this).val())
          });
        $(this).attr('href','/admin/products/export_csv.csv?products='+selected_products);
      }
      else{
        $(this).attr('href','/admin/products/export_csv.csv?products='+selected_products);
      }
      if (selected_products.length <= 50)
        displayNoticeMessage("Products are being downloaded.")
    })

    $(".admin-orders-export").click(function(event){
      var selected_orders = []
      $('.multiple-orders input[type=checkbox]:checked').each(function () {
        selected_orders.push($(this).val())
      });
      if (selected_orders.length < 1) {
        $('.multiple-orders input[type=checkbox]').each(function() {
          selected_orders.push($(this).val())
        });
        $(this).attr('href','/admin/orders/export_orders.csv?orders='+selected_orders);
      }
      else{
        $(this).attr('href','/admin/orders/export_orders.csv?orders='+selected_orders);
      }
    })
    
 });

function toggleDashboardMenu(){
  $('body').on('click', '.side-bar-nav-toggle', function(){
    var $dashboardToggleClass = $('.dashboard-page').hasClass('toggle-close');
    if($dashboardToggleClass){
      $('.dashboard-page').removeClass('toggle-close');
    }
    else {
      $('.dashboard-page').addClass('toggle-close');
    }
  });
}

function validateResetPasswordForm() {
  $('form#forgot_password_form').validate({
    ignore: "", 
    rules: {
      "admin[email]": {
        required: true
      }
    }, 
    highlight: function(element) {
      $(element).parents("div.field").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.field").removeClass('error-field');
    },
    messages: {
      "admin[email]": {
          required: "Email is required"
      }
    }
  });
}

function validateAdminSignIn() {
  $('form#new_admin').validate({
    ignore: "", 
    rules: {
      "admin[email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i
      },
      "admin[password]": {
        required: true
      },
    }, 
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "admin[email]": {
          required: "Email is required"
      },
      "admin[password]": {
        required: "Password is required"
      }
    }
  });
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
      },'Please enter a valid email address.'
  );
}

function validateChangePasswordForm() {
  $('form#admin_change_password_form').validate({
    ignore: "", 
    rules: {
      "admin[password]": {
        required: true,
        minlength: 6
      },
      "admin[password_confirmation]": {
        required: true,
        equalTo: "#admin_password"
      },
    }, 
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "admin[password]": {
          required: "Password is required",
      },
      "admin[password_confirmation]": {
        required: "Confirm password is required",
        equalTo: "Password does not match"
      }
    }
  });
}

function validateContactUsForm() {
  $('form#contact-us-form').validate({
    rules: {
      "name_field": {
        required: true,
      },
      "email_field": {
        required: true,
        email: true
      },
      "subject_field": {
        required: true,
      },
      "your_message_field": {
        required: true,
      },
    }, 
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "name_field": {
          required: "This field is required",
      },
      "email_field": {
        required: "This field is required"
      },
      "subject_field": {
        required: "This field is required"
      },
      "your_message_field": {
        required: "This field is required"
      }
    }
  });
}

window.renderHistogram = function(){
  var x1 = [];
  var x2 = [];
  var y1 = [];
  var y2 = [];
  for (var i = 1; i < 500; i++) 
  {
    k = Math.random();
    x1.push(k*5);
    x2.push(k*10);
    y1.push(k);
    y2.push(k*2);
  }
  var trace1 = {
    x: x1,
    y: y1,
    name: 'control',
    autobinx: false, 
    histnorm: "count", 
    marker: {
      color: "rgba(255, 100, 102, 0.7)", 
       line: {
        color:  "rgba(255, 100, 102, 1)", 
        width: 1
      }
    },  
    opacity: 0.5, 
    type: "histogram", 
    xbins: {
      end: 2.8, 
      size: 0.06, 
      start: .5
    }
  };
  var trace2 = {
    x: x2,
    y: y2, 
    autobinx: false, 
    marker: {
            color: "rgba(100, 200, 102, 0.7)",
             line: {
              color:  "rgba(100, 200, 102, 1)", 
              width: 1
      } 
         }, 
    name: "experimental", 
    opacity: 0.75, 
    type: "histogram", 
    xbins: { 
      end: 4, 
      size: 0.06, 
      start: -3.2
  
    }
  };
  var data = [trace1, trace2];
  var layout = {
    bargap: 0.05, 
    bargroupgap: 0.2, 
    barmode: "overlay", 
    title: "Sampled Results", 
    xaxis: {title: "Value"}, 
    yaxis: {title: "Count"}
  };
  Plotly.newPlot('myDiv', data, layout);
}

function check_form_data(formData,empty_form){
  for (let i = 0; i< formData.length;i++){
    if (formData[i].value == ''){
      empty_form.push(true)
    }else{
      empty_form.push(false)
    }
  }
  return empty_form
}

function check_subscription_form_data(formData,empty_form){
  for (let i = 0; i< formData.length;i++){
    if (formData[i].value == ''){
      if($("#rolling_subscription").prop('checked') == true && formData["subscription_months"] == ''){
        empty_form.push(false)
      }else{
        empty_form.push(true)
      }
    }else{
      empty_form.push(false)
    }
  }
  return empty_form
}

function adminManageSubscription(){
  $(".enforce-subscription-dropdown").addClass("invisible")
  dropdownHandler()
  saveSellerSubscriptionForm()
}

function dropdownHandler(){
  $("body").on("change", ".admin-subscription-status-dropdown", function(e){
    e.preventDefault();
    let option = $(this).find(":selected").val()
    if (option == "cancel")
    { 
      $("#enforce-dropdown").val("current-subscriptions-end").change();
      $(".enforce-subscription-dropdown").removeClass("invisible")
    }
    else{
      $("#enforce-dropdown").val("").change();
      $(".enforce-subscription-dropdown").addClass("invisible")
    }
  });
}

function saveSellerSubscriptionForm(){
  $(document).on("click", ".save-seller-subscription", function(e){
    e.preventDefault();
    $('#save-seller-subscription-by-admin').attr('data',$(this).attr('name'))
    $('#save-seller-subscription-confirm').modal('show');
  })

  $(document).on('submit', '#product_form', function () {
    $(this).addClass('pointer-events-none');
  })

  $(document).on('submit', '#yavolo_bundle_form', function () {
    $(this).addClass('pointer-events-none');
  })

  $(document).on("click", "#save-seller-subscription-by-admin", function(e){
    e.preventDefault();
    let that = this
    showButtonLoader(that)
    let seller = $(this).attr("data")
    let formData = $("#admin-subscription-form").serializeArray()
    let empty_form = []
    empty_form = check_form_data(formData,empty_form)
    if (empty_form.includes(false) && $("#admin-subsciption-statuses-list").find(":selected").val() !== ""){
      $.ajax({
        url: "/admin/sellers/"+seller+"/update_subscription_by_admin?id="+seller,
        type: "POST",
        data: formData,
        complete: function(){
          hideButtonLoader(that)
        }
      });
    }
    else{
      $('#save-seller-subscription-confirm').modal('hide');
      displayNoticeMessage("Please make any change to save.")
      hideButtonLoader(that)
    }

  })
}

function cardRemoveHandler(){
  $(document).on("click", ".card-delete-by-admin", function(e){
    e.preventDefault();
    $('#membership-card-remove-admin').attr('data',$(this).attr('name'))
    $('#membership-card-remove-confirm-admin').modal('show');
  })

  $(document).on("click", "#membership-card-remove-admin", function(e){
    e.preventDefault();
    let url = $(this).attr("data")
    $.ajax({
      url: url,
      type: "POST",
    });

  })
}

function renewSubscriptionHandler(){
  $(document).on("click", ".renew-seller-subscription", function(e){
    e.preventDefault();
    $('#renew-seller-subscription-by-admin').attr('data',$(this).attr('name'))
    $('#renew-seller-subscription-confirm').modal('show');
  })

  $(document).on("click", "#renew-seller-subscription-by-admin", function(e){
    e.preventDefault();
    let that = this
    showButtonLoader(that)
    let url = $(this).attr("data")
    $.ajax({
      url: url,
      type: "POST",
      complete: function(){
        hideButtonLoader(that)
      }
    });

  })
}

function removePayoutBankAccountHandler(){
  $(document).on("click", ".payout-bank-account-remove-admin", function(e){
    e.preventDefault();
    $('#stripe-payout-bank-account-admin-end').attr('data',$(this).attr('name'))
    $('#stripe-payout-bank-account-admin-confirm').modal('show');
  })

  $(document).on("click", "#stripe-payout-bank-account-admin-end", function(e){
    e.preventDefault();
    let seller = parseInt($(this).attr("data"))
    $.ajax({
      url: "/admin/sellers/"+seller+"/remove_payout_bank_account",
      type: "DELETE",
      data: {id:seller},
    });
  })
}

function contactSellerPopup(){
  $(document).on("click", "#contact-seller-modal-trigger", function(e){
    e.preventDefault();    
    $('#contact-seller-modal').modal('show');

  })
}

function verifyBankAccountForPayoutHanlder(){
  $(document).on("click", "#verify-requirments-admin-for-seller", function(e){
    e.preventDefault();
    let seller = parseInt($(this).attr("name"))
    $.ajax({
      url: "/admin/sellers/"+seller+"/verify_seller_stripe_account",
      type: "get",
      data: {id:seller},
      success: function(response){
        if (response.link){
        window.location = response.link
        }
      },
      error: function(){
        displayNoticeMessage("Link Not Found.")
      },
    });
    
  })
}

function deleteConfirmBoxMessage(selected_subscriptions){
  let msg =  selected_subscriptions.length > 1 ? 'Are you sure you want to remove these subscriptions?' : 'Are you sure you want to remove this subscription?'
  $(".confirmation-text").text(msg)
}

function createDeleteSubscription(){
  subscriptionListSelection()
  deleteDynamicPlan()
  editDynamicPlan()
  resetCreateSubscriptionPlanFormHandler()
}

function resetCreateSubscriptionPlanFormHandler(){
  $(document).on("click", "#create-new-subscription-plan-form", function(e){
    validateAgain()
    resetCreateSubscriptionPlanForm()
  })
}

function resetCreateSubscriptionPlanForm(){
  $("#create-subscription-form-submit").attr("data-type","create")
  $(".subscription-plan-title").text("Add New Subscription Type")
  $("#subscription_name,#price,#commission_excluding_vat,#subscription_months").val("")
  $('#rolling_subscription,#default_subscription').prop('checked', false);
  $("#subscription-dynamic-form").attr('action', '/admin/settings/create_subscription');
  $('#subscription_months').prop('disabled', false);
}

function subscriptionListSelection(){
  $(document).on("click", "#check-all-subscription-checkboxes", function(e){
    if ($(this).is(":checked")) {
      $("input:checkbox").not(this).prop("checked", true);
    } else {
      $("input:checkbox").not(this).prop("checked", false);
    }
  });
}

function deleteDynamicPlan(){
  deleteSubscriptionPlanHanlder()
  deleteSubscriptionPlanInitiatorHanlder()
}

function deleteSubscriptionPlanHanlder(){
  $(document).on("click", "#delete-subscription", function(e){
    e.preventDefault();
    let that = this
    if ($(this).attr("data-default") === "true"){
      displayNoticeMessage("You cannot delete a default subscription plan.")
      return false
    }
    $("#subscription-remove").attr("data",$(this).attr("data-id"))
    $('#subscription-remove-confirm').modal('show');
  })
}

function deleteSubscriptionPlanInitiatorHanlder(){
  $(document).on("click", "#subscription-remove", function(e){
    e.preventDefault();
    let plan = $(this).attr("data")
    let that = this
    showButtonLoader(that)
    $.ajax({
      url: "/admin/settings/remove_subscriptions",
      type: "DELETE",
      data: {plan:plan},
      complete: function(){
        hideButtonLoader(that)
      }
    });

  })
}

function editDynamicPlan(){
  $(document).on("click", "#subscription-plan-edit", function(e){ 
    let that = this 
    validateAgain()
    editFormResetAndMethodFormTypePopulate()
    editFormDataPopulate(that)
    editRollingPopulate(that)
    editDefaultPopulate(that)
    editActionPopulate()
  })
}

function editFormResetAndMethodFormTypePopulate(){
  $("#subscription_name,#price,#commission_excluding_vat").val("")
  $("#create-subscription-form-submit").attr("data-type","update")
  $(".subscription-plan-title").text("Edit Subscription Type")
}

function editFormDataPopulate(that){
  $("#create-subscription-form-submit").attr("data-id",$(that).attr("data-id"))    
  $("#subscription_name").val($(that).attr("data-name"))
  $("#subscription_months").val($(that).attr("data-monthx"))
  $("#price").val(Number($(that).attr("data-price")).toFixed(2))
  $("#commission_excluding_vat").val($(that).attr("data-commission"))
}

function editRollingPopulate(that){
  $('#rolling_subscription').prop('checked', false);
  $('#subscription_months').prop('disabled', false);
  if ($(that).attr("data-rolling") == "on"){
    $('#rolling_subscription').prop('checked', true);
    $('#subscription_months').prop('disabled', true);
  }
}

function editDefaultPopulate(that){
  $('#default_subscription').prop('checked', false);
  $('#default_subscription').attr("data-prev-default",false)
  if ($(that).attr("data-default") == "true"){
    $('#default_subscription').prop('checked', true);
    $('#default_subscription').attr("data-prev-default",true)
  }
}

function editActionPopulate(){
  let sub = $("#create-subscription-form-submit").attr("data-id")
  $("#subscription-dynamic-form").attr('action', '/admin/settings/update_subscription?id='+sub);
  $('#create-new-subscription').modal('show');
}

function validateAgain(){
  var validator = $( "#subscription-dynamic-form" ).validate();
  validator.resetForm();
}

function validatePlanForm(){

  $("form#subscription-dynamic-form").validate({
    ignore: "",
    submitHandler: function(form,e) {
      e.preventDefault()
      showButtonLoader("#create-subscription-form-submit")
      $("#create-subscription-form-submit").attr("type","")
      $.ajax({
        url: form.action,
        type: form.method,
        data: $(form).serialize(),
        complete: function(){
          setTimeout(function() { 
            hideButtonLoader("#create-subscription-form-submit")
            $("#create-subscription-form-submit").attr("type","submit")
        }, 1500);
        }          
    });
    },
    rules: {
      "subscription_name": {
        required: true,
        remote: function(){
          var checkit = {
              type: "get",
              url:  "/admin/settings/check_subscription_presence?sub_id="+$("#create-subscription-form-submit").attr("data-id"),
          };
          return checkit;
        }
      },
      "subscription_price": {
        required: true,
        min: 0,
        max: 999999,
        check_special_character: true
      },
      "commission_excluding_vat": {
        required: true,
        min: 0,
        max: 100,
        check_special_character: true
      },"rolling_subscription": {
        subscription_months_and_rolling: true,
      }
      ,"default_subscription": {
        default_subscription_check: true,
      },"subscription_months": {
        min: 1,
        max: 12
      }
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      "subscription_name": {
        required: "Required",
        remote: "Already exists"
      },
      "subscription_price": {
        required: "Required",
        max: "Please enter a value less than or equal to 999,999.99",
      },
      "commission_excluding_vat": {
        required: "Required",
      },
    
    },
  });

  jQuery.validator.addMethod(
    "subscription_months_and_rolling",
    function () {
      return checkRollingConditions()
    },
    "Select rolling or enter months"
  );

  jQuery.validator.addMethod(
    "default_subscription_check",
    function (value,element) {
      return checkDefaultPlan(value,element)
    },
    "Please set another plan as default first"
  );

  jQuery.validator.addMethod(
      "check_special_character",
      function(value, element) {
      return this.optional(element) || !value.includes('-')
    },
      "Invalid format"
    );

}

function checkRollingConditions(){
  result = true
  if ($("#rolling_subscription").is(":checked") === false && $("#subscription_months").val() === "" ) {
    result = false
  }
  return result
}

function checkDefaultPlan(value,element){
  let result = true
  if (element.attributes["data-prev-default"].value == 'true' && element.checked == false && $("#create-subscription-form-submit").attr("data-type") == "update"){
    result = false
  }
  return result
}

function checkPlanFormValidation(){
  rollingCheck()
  $(document).on("change","#rolling_subscription",function () {
    rollingCheck()
  });
}

function rollingCheck(){
  $("#subscription_months").prop("disabled",false)
  if ($("#rolling_subscription").is(":checked"))
    $("#subscription_months").prop("disabled",true)

}

function calculateRefund() {
  $('body').on('change', '.amount_refund', function () {
      sumOfTotalRefund();
  })
}

function sumOfTotalRefund() {
  let total_refund = 0.0;
  $('.amount_refund').each(function () {
    let amount_refund_handler = $(this).val();
    if (!isNaN(amount_refund_handler) && amount_refund_handler.length !== 0) {
      total_refund += parseFloat(amount_refund_handler);
    }
  });
  $(".total_refund").text("£" + total_refund.toFixed(2));
  $(".hidden_total_refund").val(total_refund.toFixed(2));
}

function sumOfTotalPaid() {
  let total_paid = 0.0;
  $('.amount_paid').each(function () {
    let amount_paid_handler = $(this).text().split('£').join('').replace(/,/g, '');
    if (!isNaN(amount_paid_handler) && amount_paid_handler.length !== 0) {
      total_paid += parseFloat(amount_paid_handler);
    }
  });
  $(".total_paid").text("£" + total_paid);
}

function calculateSalesCommission() {
  $(document).on("click", ".refund_option_checkboxes input:checkbox", function () {
    $('.refund_option_checkboxes input:checkbox').not(this).prop('checked', false);
      let total_commission = parseFloat($(".hidden_total_refund").val()) * parseFloat($(".commission").val() / 100);
    if ($(this).is(":checked") === true) {
      if ($(this).attr('name') === 'keep_sales_commission') {
        let net_commission = parseFloat($(".hidden_total_refund").val()) - parseFloat(total_commission);
        $(".total_refund").text("£" + net_commission.toFixed(2));
        $(".hidden_total_refund").val(net_commission.toFixed(2));
      } else if ($(this).attr('name') === 'issue_full_refund') {
        let total_refund_current = $(".hidden_total_refund").val();
        let total_refund_sum = parseFloat(total_refund_current) + parseFloat(total_commission);
        $(".total_refund").text("£" + total_refund_sum.toFixed(2));
        $(".hidden_total_refund").val(total_refund_sum.toFixed(2));
      }
    } else {
      sumOfTotalRefund();
    }
  })
}
