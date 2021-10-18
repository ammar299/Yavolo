$(document).ready(function () {
    $('#categories-tree ul:not(:first-child)').addClass('ml-4')
    $('#categories-tree li').children('ul').toggle();

    $('body').on('change', '.categories-checkbox-container .category-input', function () {
        createNewCategory($(this)[0]);
        fetchCategoryDetails($(this)[0])
    });
    $(".categories-tree-body ul:first-of-type li:first .category-input:first").prop('checked', true).trigger('change')

    $('body').on('change', '.filter-groups-select-all-container #filter-group-select-all', function () {
        if ($('#filter-group-select-all').is(':checked')) {
            $('.filter-groups-checkbox-container input:checkbox').prop('checked', true)
        } else {
            $('.filter-groups-checkbox-container input:checkbox').prop('checked', false)
        }
    });

    $('body').on('click', '#category-description-form .remove_category_image', function (e) {
        e.preventDefault();
        const url = $(this).attr('href')
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", url).attr('data-remote', true)
        $('#delete-confirmation-modal').modal('show');
    });

    $(".delete-category-action-btn").click(function (e) {
        e.preventDefault();
        const id = $(".categories-checkbox-container .category-input:checked").attr('name')
        if (!id) return;
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", `/admin/categories/${id}`).attr('data-remote', false)
        $('#delete-confirmation-modal').modal('show');
    })

    $('body').on('click', '.remove-category-products-btn', function (e) {
        e.preventDefault();
        let selected_options = []

        $('.filter-groups-checkbox-container input[type=checkbox]:checked').each(function () {
            selected_options.push($(this).val())
        });

        if (!selected_options.length > 0) return;
        const per_page = $(".category-products-per-page").val()
        const current_page = $("#category_paginator .page-item.active .page-link").text()
        const query_term = $(".category-products-search-term").val()
        const newUrl = `${$(this).attr('href')}?product_ids=${selected_options}&per_page=${per_page}&page=${current_page}&q=${query_term}`
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", newUrl).attr('data-remote', true)
        $('#delete-confirmation-modal').modal('show');
    });

    $('body').on('click', '#category_paginator .page-link', function (e) {
        e.preventDefault();
        const per_page = $(".category-products-per-page").val()
        const query_term = $(".category-products-search-term").val()
        if (!$(this).attr('href')) return;
        const newUrl = `${$(this).attr('href')}&per_page=${per_page}&q=${query_term}`
        $(this).attr('href', newUrl)
        e.returnValue = true;
    });

    $('body').on('change', '.category-products-per-page', function (e) {
        const current_page = $("#category_paginator .page-item.active .page-link").text()
        $(".category-products-form .page-number").val(current_page)
        $(".submit-category-products-form-btn").click()
    });


});

function fetchCategoryDetails(element) {
    let selected_category = $(element).attr("name")
    $.ajax({
        method: 'GET',
        url: `/admin/categories/${selected_category}/category_details`,
        success: function (data) {
            if (!data) return
            $(".category-details-wrapper").html(data)
        }
    })
}

function createNewCategory(element) {
    $(element).closest('li').find('ul').removeClass('active');
    if (element.checked) {
        $(element).closest('li').children('ul').addClass('active');
        $('.category-input').not(element).prop('checked', false);
        let is_baby_category = $(element).attr("data-baby-category") === "true"
        if (is_baby_category) {
            $('.sub-category-link').addClass('disabled');
        } else {
            $('.sub-category-link').removeClass('disabled');
        }

    } else {
        $(element).closest('li').children('ul').removeClass('active');
        $('.sub-category-link').addClass('disabled');
    }
}
