$(document).ready(function () {
    $('#categories-tree ul:not(:first-child)').addClass('ml-4')
    $('#categories-tree li').children('ul').toggle();

    $('body').on('change', '.categories-checkbox-container .category-input', function () {
        createNewCategory($(this)[0]);
        fetchCategoryDetails($(this)[0])
    });
    $(".categories-tree-body ul:first-of-type li:first .category-input").prop('checked',true).trigger('change')
});

function fetchCategoryDetails(element){
    let selected_category = $(element).attr("name")
    $.ajax({
        method: 'GET',
        url: `/admin/categories/${selected_category}/category_details`,
        success: function (data) {
            if(!data) return
            $(".category-details-wrapper").html(data)
        }
    })
}

function createNewCategory(element) {
    $(element).closest('li').find('ul').removeClass('active');
    if (element.checked) {
        $(element).closest('li').children('ul').addClass('active');
        $('.category-input').not(element).prop('checked', false);
        let selected_category = $(element).attr("name")
        let oldUrl = "/admin/categories/new";
        let subcategoryOldUrl = $(".sub-category-link").attr("href");
        $(".category-link").attr("href", `${oldUrl}?selected_cat_id=${selected_category}`)
        $(".sub-category-link").attr("href", `${subcategoryOldUrl}&selected_cat_id=${selected_category}`);
        $('.sub-category-link').removeClass('disabled');
    } else {
        $(element).closest('li').children('ul').removeClass('active');
        let oldUrl = "/admin/categories/new";
        let subcategoryOldUrl = `${oldUrl}?is_subcategory=true`
        $(".category-link").attr("href", oldUrl)
        $(".sub-category-link").attr("href", subcategoryOldUrl);
        $('.sub-category-link').addClass('disabled');
    }
}
