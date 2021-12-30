$(document).ready(function () {
  console.log("Cart js is loaded");
  // maintainCart();
  checkCartEmpty();
  cartChangeSubmit();
});

function checkCartEmpty() {
  $("body").on("click", ".remove-product-cart", function () {
    if ($('.asda').length < 1)
    {
      $("#cart").addClass("empty-card-height")
    }
  });
}

function maintainCart() {
  $("body").on("click", ".add_to_cart", function () {
    localStorageCart = getCart();
    var lineItemToAdd = $(this).data();
    var cart = [];
    if (!localStorageCart) {
      cart = [];
      cart.push({ ...lineItemToAdd, quantity: 1, added_on: Date.now() });
      storeCart("cart", cart);
    } else {
      cart = JSON.parse(localStorageCart);
      let found = false;
      cart.forEach((lineItem) => {
        if (lineItem.productId == lineItemToAdd.productId) {
          lineItem.quantity = lineItem.quantity + 1;
          found = true;
        }
      });
      if (!found) {
        cart.push({ ...lineItemToAdd, quantity: 1, added_on: Date.now() });
      }
      storeCart("cart", cart);
    }
  });
}

function getCart() {
  return localStorage.getItem("cart");
}
function storeCart(name, value) {
  localStorage.setItem(name, JSON.stringify(value));
}

// function maintainCartInSession() {
//   var cart = getCart();
//   $.ajax({
//     url: "/store_cart",
//     type: "POST",
//     dataType: "json",
//     remote: true,
//     data: {
//       cart: cart,
//     },
//     error: function (xhr) {
//       console.log("this is error");
//     },
//     success: function (res) {
//       console.log(res);
//       console.log("this is success", res);
//       $("#display-cart").html(res.html);
//     },
//   });
// }

function cartChangeSubmit() {
  $("body").on("change", ".cart-item-quantity-input", function () {
    $(this).closest("form").find("#cart-change-form-submit").trigger("click");
  });
}

function SelectedPaymentMethod() {
  
}
