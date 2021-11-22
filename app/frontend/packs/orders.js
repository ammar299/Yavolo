$(document).ready(function(){
  setOrderSearchMenuAndQueryName();
  bindWithSortByEvent();
});

function setOrderSearchMenuAndQueryName(){
  $('.admin-orders-filters a').click(function() {
    let currentFilter = $(this).text().trim();
    $('.admin-orders-filters a').removeClass('active');
    $(this).addClass('active')
    $('.current-search-filter').html(currentFilter);
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
