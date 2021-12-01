$(document).ready(function () {
  var stripe = Stripe(process.env.STRIPE_API_KEY);
  const appearance = {
    theme: "stripe",
  };

  // var cardElement = $("div").find("#card-element");
  // if (cardElement.length > 0) {
  var elements = stripe.elements();

  var elementClasses = {
    base: "form-control",
    focus: "form-control",
    empty: "form-control",
    invalid: "form-control error-field",
  };

  //   // Create an instance of the card Element.
  //   var card = elements.create("card", {
  //     classes: elementClasses,
  //   });
  //   card.mount("#card-element");
  // }
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
  // Add an instance of the card Element into the card-element <div>.
  // card.mount('#card-element');
  // registerElements([cardNumber, cardExpiry, cardCvc], "#card-element");

  var form = document.getElementById("payment-form");
  if (form) {
    form.addEventListener("submit", function (event) {
      $("#stripe-card-submit").prop("disabled", true);
      event.preventDefault();
      debugger;
      stripe.createToken(cardNumber).then(function (result) {
        debugger;
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
});
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
