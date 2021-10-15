// load all admin related js or import admin controllers js
$(document).ready(function(){
  console.log('Admin Js is loaded')

  $('.back-btn-action').click(function(){
    window.history.back();
  });
})
$(document).ready(function(){
    var hasClass = false;
    $(".parent").click(function(){
      var $ul = $(this).find('ul');
      if($(this).hasClass('active')){
        $(this).removeClass('active');
        $ul.addClass('d-none');
      }
      else {
        $(this).addClass('active');
        $ul.removeClass('d-none');
      }
    });
 });
