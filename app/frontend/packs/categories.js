$(document).ready(function () {
    $('#categories-tree ul:not(:first-child)').addClass('ml-4')
    $('#categories-tree li').children('ul').toggle();

    $('body').on('change', '.categories-checkbox-container .category-input', function () {
        createNewCategory($(this)[0]);
    });
});

function createNewCategory(element) {
    $(element).closest('li').children('ul').toggle();

    if (element.checked) {
        $('.category-input').not(element).prop('checked', false);
        let selected_category = $(element).attr("name")
        let oldUrl = "/admin/categories/new";
        let subcategoryOldUrl = $(".sub-category-link").attr("href");
        $(".category-link").attr("href", `${oldUrl}?selected_cat_id=${selected_category}`)
        $(".sub-category-link").attr("href", `${subcategoryOldUrl}&selected_cat_id=${selected_category}`);
        $('.sub-category-link').removeClass('disabled');
    } else {
        let oldUrl = "/admin/categories/new";
        let subcategoryOldUrl = `${oldUrl}?is_subcategory=true`
        $(".category-link").attr("href", oldUrl)
        $(".sub-category-link").attr("href", subcategoryOldUrl);
        $('.sub-category-link').addClass('disabled');
    }
}
