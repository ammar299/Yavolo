$(document).ready(function () {
    console.log('Buyers JS File')

    $('.click-product-quantity').click(function (e) {
        e.preventDefault();
        const quantity = $(this).data("quantity");
        $(".update-product-quantity").val(quantity);
    });

});