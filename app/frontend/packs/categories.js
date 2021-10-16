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

    $(".delete-category-action-btn").click(function (e) {
        e.preventDefault();
        const id = $(".categories-checkbox-container .category-input:checked").attr('name')
        if (!id) return;
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", `/admin/categories/${id}`)
        $('#delete-confirmation-modal').modal('show');
    })
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
