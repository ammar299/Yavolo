// load all admin related js or import admin controllers js
$(document).ready(function(){
  console.log('Admin Js is loaded')

  $('.back-btn-action').click(function(){
    window.history.back();
  });
  validateAdminSignIn()

  $('#admin-subsciption-statuses-list').change(function(e){
    e.preventDefault();
    $('#stripe-subscription-cancel-by-admin').attr('data',$(this).find(":selected").data("seller"))
    $(".confirmation-text").attr('name',$(this).find(":selected").val())
    $('#stripe-subscription-end-by-admin-confirm').modal('show');
  });
  
  $('#stripe-subscription-cancel-by-admin').click(function(e){
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

    // for hightlighting the sidemenu bar current option
    let pathName = window.location.pathname.split('/');
    pathName = "/"+pathName[1]+"/"+pathName[2]
    $(".leftside a").each(function(){
      $(this).parent().removeClass("active")
      try {
        let linkHref = $(this).attr('href').split('/')
        linkHref = "/"+linkHref[1]+"/"+linkHref[2]
        if (linkHref === pathName)
        {
          $(this).parent().addClass("active")
          if ($(this).parent().parent().hasClass("d-none")){
            $(this).parent().parent().removeClass("d-none")
          }
        }
        else if(pathName === '//undefined'){
        $(".icon-dashboard").parent().parent().addClass("active")
        }
      }
      catch {

      }
    });
   
    $(".export-csv-selected-sellers").click(function(){
      var selected_sellers = []
      $('.multiple-update-sellers input[type=checkbox]:checked').each(function () {
      selected_sellers.push($(this).val())
      });
      if (selected_sellers.length < 1) {
        $("#export-seller-failure").addClass("notice-msg")
        setTimeout(() => { 
            $("#export-seller-failure").removeClass("notice-msg")
        }, 3000);
        return false
      }
      else{
        $(this).attr('href','/admin/export_sellers.csv?sellers='+selected_sellers)
        $("#export-seller-sucsess").addClass("notice-msg")
        setTimeout(() => { 
            $("#export-seller-sucsess").removeClass("notice-msg")
        }, 3000);
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
      },'Please Enter a valid Email'
  );
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

