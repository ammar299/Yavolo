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

    // for hightlighting the sidemenu bar current option
    let pathName = window.location.pathname.split('/');
    pathName = "/"+pathName[1]+"/"+pathName[2]
    $("a").each(function(){
      $(this).parent().removeClass("active")
      let linkHref = $(this).attr('href').split('/')
      linkHref = "/"+linkHref[1]+"/"+linkHref[2]
      if (linkHref === pathName)
      {
        $(this).parent().addClass("active")
        if ($(this).parent().parent().hasClass("d-none")){
          $(this).parent().parent().removeClass("d-none")
        }
      }
      else if(pathName === '//undefined'){
      $(".icon-dashboard").parent().parent().addClass("active")
      }
    });
   
 });
