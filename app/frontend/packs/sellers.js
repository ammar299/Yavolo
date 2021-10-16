$(document).ready(function(){
  console.log('sellers js is loaded');
  sellerSearchByFilter();
});

function sellerSearchByFilter(){
  var $sellerDropDown = $('.seller-search-dropdown');
  var $sellerSearchField = $('.seller-search-field');
  var $sellerFilterTypeField = $('#seller-filter-type');
  $('#seller-serarch-by-toggle a').click(function(e){
    var $currFilter = $(this).text().trim();
    e.preventDefault();
    $sellerDropDown.text($(this).text());
    if($currFilter === 'Username'){
      $sellerSearchField.attr('name', 'q[first_name_or_last_name_cont]');
      $sellerFilterTypeField.val('Username');
    }
    else if($currFilter === 'Email'){
      $sellerSearchField.attr('name', 'q[email_cont]');
      $sellerFilterTypeField.val('Email');
    }
    else {
      $sellerSearchField.attr('name', 'q[first_name_or_last_name_or_email_cont]');
      $sellerFilterTypeField.val('Search All');
    }
  });
}
