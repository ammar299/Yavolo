// $(document).ready(function(){
//   var stripe = Stripe('pk_test_51IfjFUFqSiWsjxhXbRrObdGnNbi0HGp64DKuqsivFjJN81Dip3ZpRAFUKGrOxhZkAoRZMbEOSLr7SAvvk6bmDvTu00eJrWMQB2');
//   var elements = stripe.elements();

//   var style = {
//     base: {
//       // Add your base input styles here. For example:
//       fontSize: '14px',
//       color: '#640529',
//       padding: '1em',
//     },
//     invalid: {
//       iconColor: 'red',
//       color: 'red',
//     },

//   };

//   // Create an instance of the card Element.
//   var card = elements.create('card', {style: style});

//   // Add an instance of the card Element into the `card-element` <div>.
//   card.mount('#card-element');


//   var form = document.getElementById('payment-form');
//   form.addEventListener('submit', function(event) {
//     $("#stripe-card-submit").prop('disabled',true)
//     event.preventDefault();
//     stripe.createToken(card).then(function(result) {
//       if (result.error) {
//         // Inform the customer that there was an error.
//         $("#stripe-card-submit").prop('disabled',false)
//         var errorElement = document.getElementById('card-errors');
//         errorElement.textContent = result.error.message;
        
//       } else {
//         // Send the token to your server.
//         stripeTokenHandler(result.token);
//       }
//     });
//   });

// });

// function stripeTokenHandler(token) {

//   // Insert the token ID into the form so it gets submitted to the server
//   var form = document.getElementById('payment-form');
//   var hiddenInput = document.createElement('input');
//   hiddenInput.setAttribute('type', 'hidden');
//   hiddenInput.setAttribute('name', 'stripeToken');
//   hiddenInput.setAttribute('value', token.id);
//   form.appendChild(hiddenInput);
//   var dataString = $("#payment-form").serialize();
//   $.ajax({
//     type: "POST",
//     url: "/sellers/payment_methods",
//     data: dataString
//   });
//   // Submit the form
//   // form.submit();
// }