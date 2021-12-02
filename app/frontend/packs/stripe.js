$(document).ready(function () {
  $("body").on("click", ".submit-checkout-details", function (e) {
    e.preventDefault();
    // $("#stripe-card-submit").prop('disabled', false);
    loadStripeForCheckoutForm();
  });
});

function loadStripeForCheckoutForm() {
  // var stripe = Stripe(process.env.STRIPE_API_KEY);
  var elements = stripe.elements();

  var cardElement = $("div").find("#stripe-card-elements");
  if (cardElement.length > 0) {
    var cardNumber = elements.create("cardNumber", {
      classes: {
        base: "form-control",
        focus: "form-control",
        empty: "form-control",
        invalid: "form-control error-field",
      },
      showIcon: true,
    });
    cardNumber.mount("#card-number");

    var cardExpiry = elements.create("cardExpiry", {
      classes: {
        base: "form-control payment-input",
        focus: "form-control payment-input",
        empty: "form-control payment-input",
        invalid: "form-control payment-input error-field",
      },
      showIcon: true,
    });
    cardExpiry.mount("#card-expiry");

    var cardCvc = elements.create("cardCvc", {
      classes: {
        base: "form-control",
        focus: "form-control",
        empty: "form-control",
        invalid: "form-control error-field",
      },
      showIcon: true,
    });
    cardCvc.mount("#card-cvc");
  }

  var form = document.getElementById("payment-form");
  if (form) {
    form.addEventListener("submit", function (event) {
      $("#stripe-card-submit").prop("disabled", true);
      event.preventDefault();
      stripe.createToken(cardNumber).then(function (result) {
        if (result.error) {
          // Inform the customer that there was an error.
          $("#stripe-card-submit").prop("disabled", false);
          var errorElement = document.getElementById("card-errors");
          $(".stripe-card-validation").addClass("error-field");
          errorElement.textContent = result.error.message;
        } else {
          $(".stripe-card-validation").removeClass("error-field");
          $("#card-errors").removeClass("error");
          // Send the token to your server.
          stripeTokenHandler(result.token);
        }
      });
    });
  }
}

function stripeTokenHandler(token) {
  // Insert the token ID into the form so it gets submitted to the server
  var form = document.getElementById("payment-form");
  var hiddenInput = document.createElement("input");
  hiddenInput.setAttribute("type", "hidden");
  hiddenInput.setAttribute("name", "stripeToken");
  hiddenInput.setAttribute("value", token.id);
  form.appendChild(hiddenInput);

  // Submit the form
  form.submit();
}
