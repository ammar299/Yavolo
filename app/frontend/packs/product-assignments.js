$(document).ready(function () {
    $(".product-assignment-tabs .nav-link").click(function () {
        if ($(this).hasClass('active')) {
            // Tab already selected
            return;
        }
        const tabType = $(this).attr('data-tab-type')
        const hiddenLink = $(".product-assignment-tab-hidden-link")
        const originalUrl = hiddenLink.attr('data-original-url')
        const newUrl = `${originalUrl}?current_tab=${tabType}`
        hiddenLink.attr('href', newUrl)
        hiddenLink[0].click()
    })
});