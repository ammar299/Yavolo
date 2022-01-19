$(document).ready(function () {
    setOrderSearchMenuAndQueryName();
    bindWithSortByEvent();
    bindResultPerPageOption();
    selectOptionForRefundReason();
    buyerOrderSliderEvent()
    removeOrdersFilter();
    removeOrdersSearch();

    $('.order-mark-bulk-update').change(function () {
        $('.order-table-row').find('input:checkbox').prop('checked', $(this).is(':checked'));
    });

    $(".multiple-orders input").click(function () {
        if (!$(this).is(":checked")) {
            $(".order-mark-bulk-update").prop("checked", false);
        }
    });
});

function setOrderSearchMenuAndQueryName() {
    $('.cls-admin-orders-filters a').click(function (e) {
        e.preventDefault();
        let currentFilter = $(this).text().trim();
        let searchField = $('.admin-order-search-field');
        let filterType = $('#order-filter-type');
        $('.cls-admin-orders-filters a').removeClass('active');
        $(this).addClass('active');
        $("input[name='q[s]']").remove();
        $('.current-search-filter').html(currentFilter + ' <i class="fa fa-angle-down ml-2" aria-hidden="true"></i>');
        if (currentFilter === 'Product Title A-Z') {
            searchField.attr('name', 'q[search_product_a_to_z]');
            $('#csfn').val('search_product_a_to_z');
            filterType.val('Product Title A-Z');
            $('#order_search').append('<input type="hidden" name="q[s]" id="q_s">')
            $('#q_s').val('line_items_product_title asc');
        } else if (currentFilter === 'Product Title Z-A') {
            searchField.attr('name', 'q[search_product_z_to_a]');
            $('#csfn').val('search_product_z_to_a');
            filterType.val('Product Title Z-A');
            $('#order_search').append('<input type="hidden" name="q[s]" id="q_s">')
            $('#q_s').val('line_items_product_title desc');
        } else if (currentFilter === 'Order Number') {
            searchField.attr('name', 'q[order_number_cont]');
            $('#csfn').val('order_number_cont');
            filterType.val('Order Number');
        } else if (currentFilter === 'Seller Name') {
            searchField.attr('name', 'q[line_items_product_owner_of_Seller_type_full_name_cont]');
            $('#csfn').val('line_items_product_owner_of_Seller_type_full_name_cont');
            filterType.val('Seller Name');
        } else if (currentFilter === 'Customer Name') {
            searchField.attr('name', 'q[order_detail_full_name_cont]');
            $('#csfn').val('order_detail_full_name_cont');
            filterType.val('Customer Name');
        } else if (currentFilter === 'SKU') {
            searchField.attr('name', 'q[line_items_product_sku_cont]');
            $('#csfn').val('line_items_product_sku_cont');
            filterType.val('SKU');
        } else {
            searchField.attr('name', 'q[line_items_product_title_or_order_number_or_line_items_product_owner_of_Seller_type_full_name_or_order_detail_full_name_or_line_items_product_sku_cont]');
            $('#csfn').val('line_items_product_title_or_order_number_or_line_items_product_owner_of_Seller_type_full_name_or_order_detail_full_name_or_line_items_product_sku_cont');
            filterType.val('Search All');
        }
    });
}

function bindWithSortByEvent() {
    $('.sortby-orders').click(function (e) {
        e.preventDefault();
        if ($('#q_s').length === 0) {
            $('#order_search').append('<input type="hidden" name="q[s]" id="q_s">');
        }
        $('#q_s').val($(this).data('sortby'));
        $('form#order_search').submit();
    });
}

function bindResultPerPageOption(){
    $('.perpage-option').click(function(e){
        e.preventDefault();
        if($('#per_page').length > 0){
            $('#per_page').val($(this).data('per-page'));
        }else{
            $('#order_search').append('<input type="hidden" name="per_page" id="per_page">')
            $('#per_page').val($(this).data('per-page'));
        }
        $('form#order_search').submit();
    })
}

function selectOptionForRefundReason() {
    $(".refund-reason-dropdown a").click(function (e) {
        e.preventDefault();
        $('.refund-reason-dropdown a').removeClass('active');
        $(this).addClass('active');
        let currVal = $(this).text().trim();
        $('.refund-reason-display-val').html(currVal +' <i class="fa fa-angle-down ml-3" aria-hidden="true" />');
        $("#refund-reason-value").val(currVal.toLowerCase().replace(/ /g,"_"));
    });
}

function buyerOrderSliderEvent(){
    $('.orders-slider').slick({
    infinite: true,
    speed: 300,
    slidesToShow: 1,
    slidesToScroll: 1,
    autoplay: true,
    padding: 10,
    responsive: [{
        breakpoint: 1025,
        settings: {
            slidesToShow: 1,
            slidesToScroll: 1,
        }
        },
        {
        breakpoint: 600,
        settings: {
            slidesToShow: 1,
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

function removeOrdersFilter() {
    $('body').on('click', '.rm-filterby', function() {
        $('#q_s').val('');
        $('form#order_search').submit();
    });
}

function removeOrdersSearch() {
    $('body').on('click', '.rm-orders-search', function(e) {
        e.preventDefault();
        $('.admin-order-search-field').val('');
        $('form#order_search').submit();
    });
}
