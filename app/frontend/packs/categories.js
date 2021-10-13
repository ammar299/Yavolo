$(document).ready(function(){
  $('#categories-tree ul:not(:first-child)').addClass('ml-4')
  $('#categories-tree li').children('ul').toggle();

  $('body').on('change', '.categories-checkbox-container #category-id', function(){
    createNewCategory($(this));
  });
});

function createNewCategory($this) {
  $this.closest('li').children('ul').toggle();
  $('input[type="checkbox"]').prop('checked', false);
  $this.prop('checked', true);

  // please check belows line. these lines are not working for a while
  if ($this.checked) {
    $('.category_id').not($this).prop('checked', false);
    let parent = $($this).attr("name")
    oldUrl = "/admin/categories/new";
    $(".sub-category-link").attr("href", oldUrl+"?parent_id="+parent);
    $('.sub-category-link').removeClass('disabled');
  }
  else{
    oldUrl = "/admin/categories/new";
    $(".sub-category-link").attr("href", oldUrl);
    $('.sub-category-link').addClass('disabled');
  }
}
