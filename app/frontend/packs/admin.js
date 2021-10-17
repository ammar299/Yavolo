// load all admin related js or import admin controllers js
$(document).ready(function(){
  console.log('Admin Js is loaded')

  $('.back-btn-action').click(function(){
    window.history.back();
  });
})
$(document).ready(function(){
  toggleDashboardMenu();
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
    $(".leftside a").each(function(){
      $(this).parent().removeClass("active")
      try {
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
      }
      catch {

      }
    });
   
 });

function toggleDashboardMenu(){
  $('body').on('click', '.side-bar-nav-toggle', function(){
    var $dashboardToggleClass = $('.dashboard-page').hasClass('toggle-close');
    if($dashboardToggleClass){
      $('.dashboard-page').removeClass('toggle-close');
    }
    else {
      $('.dashboard-page').addClass('toggle-close');
    }
  });
}
