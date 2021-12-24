$(document).ready(function () {
    console.log('Buyers JS File')
		disableEnterOnAddToCart();
		disableAddToCartForm();
    restrictQuantityValue();
    activeCheckoutPath();
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
