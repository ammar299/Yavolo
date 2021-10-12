// load all products related js here
$(document).ready(function(){
  // bindDragAndDropPhotosEvents();
  console.log('products js is loaded');
  $('#product_pictures_attributes_0_name').change(function(e){
    previewProductImages(e.target.files);
  });

  // show upload images popup
  $('.show-upload-images-popup').click(function(e){
    e.preventDefault();
    $('#upload-images-popup').modal('show');
    console.log('asdfjalfajflaj')
  });

});

function previewProductImages(files){
  let preveiwImagesTemplate = [];
  for(let i=0; i<files.length; i++ ){
    preveiwImagesTemplate.push(imageTemplate(URL.createObjectURL(files[i])));
  }
  if($('.product-photos-grid').length > 0){
    $('.product-photos-grid').append(preveiwImagesTemplate.join(""));
    $('.add-edit-product-photos').removeClass('col-lg-12').addClass('col-lg-8');
    $('.product-photos-section').show();
    $('#upload-images-popup').modal('hide');
  }
}

function bindDragAndDropPhotosEvents(){
  let dropArea = document.getElementById('upload-images-popup')
  ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false)
  })

  ;['dragenter', 'dragover'].forEach(eventName => {
    dropArea.addEventListener(eventName, highlight, false)
  })

  ;['dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, unhighlight, false)
  })

  dropArea.addEventListener('drop', handleDrop, false)

}

function preventDefaults (e) {
  e.preventDefault()
  e.stopPropagation()
}

function highlight(e) {
  console.log('entered ')
  let dropArea = document.getElementById('upload-images-popup')
  dropArea.classList.add('highlight')
}

function unhighlight(e) {
  console.log('left')
  let dropArea = document.getElementById('upload-images-popup')
  dropArea.classList.remove('highlight')
}

function handleDrop(e) {
  let dt = e.dataTransfer
  let files = dt.files

  previewProductImages(files)
}

function imageTemplate(path){
  let template = "";
  template += '<div class="col-md-4 p-1">';
  template +=  '<div class="grid-single-img">';
  template +=      '<span>';
  template +=          '<img src="'+path+'" alt="">';
  template +=      '</span>';
  template +=      '<div class="img-star-icon">';
  template +=          '<span class="icon-reviews"></span>';
  template +=      '</div>';
  template +=      '<div class="img-del-icon">';
  template +=          '<span class="fas fa-trash-alt"></span>';
  template +=      '</div>';
  template +=  '</div>';
  template += '</div>';
  return template;
}


