$(document).ready(function () {
    setOrderSearchMenuAndQueryName();
    bindWithSortByEvent();
    bindResultPerPageOption();

    $('.order-mark-bulk-update').change(function () {
        $('.order-table-row').find('input:checkbox').prop('checked', $(this).is(':checked'));
    });

    $('.order-bulk-actions a.dropdown-item').click(function (e) {
        e.preventDefault();
        if ($('.order-table-row input[type=checkbox]:checked').length > 0) {
            $('.container-fluid').find('.alert').remove();
            $('.order-bulk-actions a.dropdown-item').removeClass('active');
            $(this).addClass('active');
            let action = $('.order-bulk-actions a.dropdown-item.active').data('bulkaction');
            if (['view'].includes(action)) {
                $('#admin-orders-confirm').modal('show');
            }
        } else {
            showErrorsAlert(['You have not selected any orders to update']);
        }
    });

    $('#yes-perform-action').click(function (e) {
        e.preventDefault();
        $('#admin-orders-confirm').modal('hide');
        if($('.order-bulk-actions').length == 0) return;
        updateBulkOrders($('.order-bulk-actions a.dropdown-item.active').data('bulkaction'));
        $('.order-bulk-actions a.dropdown-item').removeClass('active');
    })

    function updateBulkOrders(action) {
        let orderIds = []
        $('.order-table-row input[type=checkbox]:checked').each(function () {
            orderIds.push($(this).val())
        })
        if (orderIds.length === 0) {
            showErrorsAlert(['Error: param value is missing.']);
            return false;
        }
        if (action === 'view') {
            $('.order-table-row input[type=checkbox]:checked').parents('.order-table-row').each(function () {
                let pid = $(this).attr('id').split('-')[$(this).attr('id').split('-').length - 1];
                window.open(window.location.protocol + "//" + window.location.host + "/admin/orders/" + pid, '_blank').focus();
            });
        }
        $('.order-listing-table').find('input[type=checkbox]:checked').prop('checked', false).trigger('change')
    }

    function showErrorsAlert(errors) {
        $('.container-fluid').find('.alert').remove();
        let alertErrors = '<div class="flash-toast alert alert-msg text-left"><ul>' + errors.map(e => "<li>" + e + "</li>").join("") + '</ul><span class="notice-cross-icon" aria-hidden="true">&times;<span></div>';
        $('.container-fluid').prepend(alertErrors);
    }
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
            searchField.attr('name', 'q[line_items_product_title_cont]');
            $('#csfn').val('line_items_product_title_cont');
            filterType.val('Product Title A-Z');
            $('#order_search').append('<input type="hidden" name="q[s]" id="q_s">')
            $('#q_s').val('line_items_product_title asc');
        } else if (currentFilter === 'Product Title Z-A') {
            searchField.attr('name', 'q[line_items_product_title_cont]');
            $('#csfn').val('line_items_product_title_cont');
            filterType.val('Product Title Z-A');
            $('#order_search').append('<input type="hidden" name="q[s]" id="q_s">')
            $('#q_s').val('line_items_product_title desc');
        } else if (currentFilter === 'Customer Name') {
            searchField.attr('name', 'q[order_detail_name_cont]');
            $('#csfn').val('order_detail_name_cont');
            filterType.val('Customer Name');
        } else if (currentFilter === 'SKU') {
            searchField.attr('name', 'q[line_items_product_sku_cont]');
            $('#csfn').val('line_items_product_sku_cont');
            filterType.val('SKU');
        } else {
            searchField.attr('name', 'q[line_items_product_title_or_order_detail_customer_name_cont_or_line_items_product_sku_cont]');
            $('#csfn').val('line_items_product_title_or_order_detail_customer_name_cont_or_line_items_product_sku_cont');
            filterType.val('Search All');
        }
    });
}

function bindWithSortByEvent() {
    $('.sortby-orders').click(function (e) {
        e.preventDefault();
        $('#order_search').append('<input type="hidden" name="q[s]" id="q_s">')
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
