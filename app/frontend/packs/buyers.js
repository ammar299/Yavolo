$(document).ready(function () {
    console.log('Buyers JS File')
		disableEnterOnAddToCart();
		disableAddToCartForm();
    restrictQuantityValue();
    activeCheckoutPath();
    validateBuyerSignInSignUp();
    // buyerAccountPageSlider() TODO: arhum -> resolve slick issue if you need this function.
    buyerYaFavouritesSlider()
    $('.click-product-quantity').click(function (e) {
        e.preventDefault();
        const quantity = $(this).data("quantity");
        $(".update-product-quantity").val(quantity);
    });

    $(".update-product-quantity").on('input', function () {
        changeQtyofInput();
    });

    $('body').on('click', '.click-product-quantity', function(){
        $(".update-product-quantity").trigger('change');
        changeQtyofInput();
    });     

    function changeQtyofInput(){
			let stock = $('#product_quantity').data('quantity');
      let qty_val = $("#product_quantity").val();
			if(qty_val == 0 || qty_val > stock) {
        $("#quantity-error").remove();
				if($("#quantity-error").length == 0) {
					$("#buy_button, #add_basket_button").attr("disabled", true);
					if (qty_val > stock) {
						$("#dropdownMenuButton").after('<label  id= "quantity-error" class="text-left w-100 error text-">Available stock is ' + stock +'</label>');
					}else {
						$("#dropdownMenuButton").after('<label  id= "quantity-error" class="text-left w-100 error text-">Please select quantity</label>');
					}
				}
			}
			else {
				$("#quantity-error").remove();
				$("#buy_button, #add_basket_button").attr("disabled", false);
			}
		}
});

function disableEnterOnAddToCart() {
	$('#buyer-products-quantity').on('keyup keypress', function(e) {
    var keyCode = e.keyCode || e.which;
    if (keyCode === 13) {
      e.preventDefault();
    }
  });
}

function disableAddToCartForm() {
	$('#buy_button, #add_basket_button').click(function (e) {
		let stock = $('#product_quantity').data('quantity');
    if($("#product_quantity").val() == 0 || $("#product_quantity").val() > stock) {
      e.preventDefault();
    }
  });
}

function restrictQuantityValue() {
  $('.update-product-quantity').keypress(function(e) {
    var verified = (e.which == 8 || e.which == undefined || e.which == 0) ? null : String.fromCharCode(e.which).match(/[^0-9]/);
    if (verified || e.delegateTarget.value.length > 3 || e.ctrlKey ==true) {
      if(e.which!=8 ) {
        e.preventDefault();
      }
    }
  }).on('paste',function(e) {
    e.preventDefault();
  });
}

function activeCheckoutPath() {
  let action = $('.innerSteps').data('url')
  if (action == 'new') {
    $('.checkout-new').addClass('active');
  }
  else if (action == 'payment_method') {
    $('.checkout-new').addClass('active');
    $('.checkout-payment-method').addClass('active');
  }
  else {
    $('.checkout-new').addClass('active');
    $('.checkout-payment-method').addClass('active');
    $('.checkout-review-order').addClass('active');
  }
}


function validateBuyerSignInSignUp() {
  $("form#new_buyer").validate({
    rules: {
      "buyer[first_name]": {
        required: true,
      },
      "buyer[surname]": {
        required: true,
      },
      "buyer[email]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
      },
      "buyer[email_confirmation]": {
        required: true,
        email: true,
        regex: /^\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b$/i,
        equalTo: "#buyer_email",
      },
      "buyer[password]": {
        required: true,
        buyer_password_validation: true,
      },
      "buyer[password_confirmation]": {
        required: true,
        equalTo: "#buyer_password",
      },
    },
    highlight: function (element) {
      $(element).parents("div.form-group").addClass("error-field");
    },
    unhighlight: function (element) {
      $(element).parents("div.form-group").removeClass("error-field");
    },
    messages: {
      "buyer[first_name]": {
        required: "First name is required",
      },
      "buyer[surname]": {
        required: "Surname name is required",
      },
      "buyer[email]": {
        required: "Email is required",
      },
      "buyer[email_confirmation]": {
        required: "Email confirmation is required",
        equalTo: "Email does not match",
      },
      "buyer[password]": {
        required: "Password is required",
      },
      "buyer[password_confirmation]": {
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

function buyerAccountPageSlider(){
  $('.pdp-nbg-slick-slider').slick({
    infinite: true,
    speed: 300,
    slidesToShow: 6,
    slidesToScroll: 6,
    autoplay: false,
    padding: 10,
    responsive: [{
        breakpoint: 1025,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 1,
        }
      },
      {
        breakpoint: 600,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 1
        }
      },
      {
        breakpoint: 480,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1
        }
      }
    ]
  });
}

function buyerYaFavouritesSlider(){
  $('.pdp-slick-slider-ya-faourites').slick({
    infinite: true,
    speed: 300,
    slidesToShow: 4,
    slidesToScroll: 1,
    autoplay: false,
    padding: 10,
    responsive: [{
        breakpoint: 1025,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
        }
      },
      {
        breakpoint: 800,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 1
        }
      },
      {
        breakpoint: 480,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1
        }
      }
    ]
  });
}
