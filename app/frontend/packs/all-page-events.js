$(document).ready(function(){
  $('.notice-cross-icon').click(function(){
    $('.flash-toast').removeClass('notice-msg');
    $('.flash-toast').removeClass('alert-msg');
  });

  $('body').on('click', '.menu-icon', function(){
    $('.leftside').toggleClass('leftside-open');
  });
});
