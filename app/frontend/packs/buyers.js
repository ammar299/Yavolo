$(document).ready(function () {
    console.log('Buyers JS File')

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
        if($("#product_quantity").val() < 1 || $("#product_quantity").val().length == 0)
        {
            if($("#quantity-error").length == 0)
            {
                $("#buy_button, #add_basket_button").attr("disabled", true);
                $("#dropdownMenuButton").after('<label  id= "quantity-error" class="text-left w-100 error text-">Please select quantity</label>');
            }
        }
        else
        {
            $("#quantity-error").remove();
            $("#buy_button, #add_basket_button").attr("disabled", false);
        }
    }
});
