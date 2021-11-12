$(document).ready(function(){
  setOrderSearchMenuAndQueryName();
});

function setOrderSearchMenuAndQueryName(){
  $('.admin-orders-filters a').click(function() {
    let currentFilter = $(this).text().trim();
    $('.admin-orders-filters a').removeClass('active');
    $(this).addClass('active')
    $('.current-search-filter').html(currentFilter);
  });
}
