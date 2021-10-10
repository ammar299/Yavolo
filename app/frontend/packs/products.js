// load all products related js here
$(document).ready(function(){
  console.log('products js is loaded');
  $('#product_pictures_attributes_0_name').change(previewProductImages);
});

function previewProductImages(event){
  let preveiwImagesTemplate = [];
  for(let i=0; i<event.target.files.length; i++ ){
    preveiwImagesTemplate.push('<img onload="$(this).removeClass(\'loadinng\')" width="100" height="100" src="'+URL.createObjectURL(event.target.files[i])+'" />');
  }
  $('.photos-section').html("");
  $('.photos-section').append('<div style="width: 500px; height: 500px">'+preveiwImagesTemplate.join("")+'</div>');
  // loadImages();
}


