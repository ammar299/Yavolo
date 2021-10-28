$(document).ready(function () {
  $(".notice-cross-icon").click(function () {
    $(".flash-toast").removeClass("notice-msg");
    $(".flash-toast").removeClass("alert-msg");
  });
  $("body").on("click", ".view-api-token", function () {
    $(this).next().removeClass("d-none");
    $(this).hide();
  });

  $("body").on("click", ".seller-api-token", function () {
    var text = $(this).text().trim();
    copyToClipboard(text);
  });

  $(".api-token").hover(function () {
    $(".help-popup-text").text("Click to Copy");
  });

  $('body').on('click', '.menu-icon', function(){
    $('.leftside').toggleClass('leftside-open');
  });
});

function copyToClipboard(element) {
  var $temp = $("<input>");
  $("body").append($temp);
  $temp.val(element).select();
  document.execCommand("copy");
  $temp.remove();
  $(".help-popup-text").text("copied");
}
