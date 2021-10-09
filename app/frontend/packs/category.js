$('.category_id').change(function() {     
    
  if (this.checked) {
    $('.category_id').not(this).prop('checked', false);
    let parent = $(this).attr("name")
    oldUrl = "/admin/categories/new"; 
    $(".sub-category-link").attr("href", oldUrl+"?parent_id="+parent);
    $('.sub-category-link').removeClass('disabled');
  }
  else{
    oldUrl = "/admin/categories/new"; 
    $(".sub-category-link").attr("href", oldUrl);
    $('.sub-category-link').addClass('disabled');
  }

});