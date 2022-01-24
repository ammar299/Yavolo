$(document).ready(function () {
  console.log('google pay is ready');
  if (window.location.pathname.includes("cart")) {
    ifCartIsNotEmpty();
  }
});

function ifCartIsNotEmpty() {
  if ($('#display-cart').length > 0 && $('#display-cart')[0].childNodes.length > 0) {
    googlePayPayment();
  }
}

function googlePayPayment() {
  // 1. Initialize Stripe
  const stripe = Stripe('pk_test_51IfjFUFqSiWsjxhXbRrObdGnNbi0HGp64DKuqsivFjJN81Dip3ZpRAFUKGrOxhZkAoRZMbEOSLr7SAvvk6bmDvTu00eJrWMQB2');

  const cart_total = Number($('#cart-total-hidden').val());

  // 2. Create a payment request object
  var paymentRequest = stripe.paymentRequest({
    country: 'GB',
    currency: 'gbp',
    total: {
      label: 'Total',
      amount: Math.round(cart_total*100),
    },
    requestPayerName: true,
    requestPayerEmail: true,
    requestPayerPhone: true,
    requestShipping: true,
    shippingOptions: [{
      id: 'basic-free-shipping',
      label: 'Free Shipping',
      detail: 'Standard shipping via Post (Free Shipping)',
      amount: 0,
    }]
  });

  // 3. Create a PaymentRequestButton element
  const elements = stripe.elements();
  const prButton = elements.create('paymentRequestButton', {
    paymentRequest: paymentRequest,
  });

  // Check the availability of the Payment Request API,
  // then mount the PaymentRequestButton
  paymentRequest.canMakePayment().then(function (result) {
    if (result) {
      console.log('can make payment result',result)
      prButton.mount('#payment-request-button');
    } else {
      // document.getElementById('payment-request-button').style.display = 'none';
      console.log('Google Pay support not found. Check the pre-requisites above and ensure you are testing in a supported browser.');
    }
  });

  paymentRequest.on('paymentmethod', async (e) => {

    const buyerDetails = {
      buyerName: e.payerName,
      buyerEmail: e.payerEmail,
      buyerPhone: e.payerPhone,
      paymentMethod: e.paymentMethod,
      shippingDetails: e.shippingAddress
    }

    // Make a call to the server to create a new
    // payment intent and store its client_secret.
    const {error: backendError, clientSecret} = await fetch(
      '/create_google_payment',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          currency: 'gbp',
          paymentMethodType: 'card',
          buyerDetails: buyerDetails
        }),
      }
    ).then((r) => r.json());

    if (backendError) {
      console.log(backendError.message);
      e.complete('fail');
      return;
    }

    console.log(`Client secret returned.`);
    console.log('client secret', clientSecret);
    console.log('event', e);

    // Confirm the PaymentIntent without handling potential next actions (yet).
    let {error, paymentIntent} = await stripe.confirmCardPayment(
      clientSecret,
      {
        payment_method: e.paymentMethod.id,
      },
      {
        handleActions: false,
      }
    );

    if (error) {
      console.log(error.message);

      // Report to the browser that the payment failed, prompting it to
      // re-show the payment interface, or show an error message and close
      // the payment interface.
      e.complete('fail');
      return;
    }
    // Report to the browser that the confirmation was successful, prompting
    // it to close the browser payment method collection interface.
    e.complete('success');

    // Check if the PaymentIntent requires any actions and if so let Stripe.js
    // handle the flow. If using an API version older than "2019-02-11" instead
    // instead check for: `paymentIntent.status === "requires_source_action"`.
    if (paymentIntent.status !== 'succeeded' || paymentIntent.status !== 'canceled') {
      // Let Stripe.js handle the rest of the payment flow.
      let {error, paymentIntent} = await stripe.confirmCardPayment(
        clientSecret
      );
      if (error) {
        // The payment failed -- ask your customer for a new payment method.
        console.log('paymentIntent Require actions',error.message);
        return;
      }
      console.log(`Payment ${paymentIntent.status}: ${paymentIntent.id}`);
      console.log('payment requires action paymentIntent',paymentIntent);
    }
    else if (paymentIntent.status === 'canceled') {
      console.log('paymentIntent canceled');
      return;
    }

    console.log(`Payment ${paymentIntent.status}: ${paymentIntent.id}`);
    console.log('paymentIntent',paymentIntent)

    const confirmationResponse = await fetch(
      '/confirm_google_pay_payment',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          paymentIntentId: paymentIntent.id,
          buyerDetails: buyerDetails
        }),
      }
    ).then((r) => r.json());

    // if (responseError) {
    //   console.log('error message', error.message);
    //   return;
    // }
    if (confirmationResponse) {
      // alert('COMPLETED');
      // REDIRECT TO SUCCESS PAGE
      window.location.replace(`/order_completed?order=${confirmationResponse.order.id}`);
    }
  });
}