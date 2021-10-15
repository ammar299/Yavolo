// load all products related js here
$(document).ready(function(){
  // bindDragAndDropPhotosEvents();
  if(document.getElementById('upload-csv-popup'))
    bindDragAndDropEvents('upload-csv-popup');

  $('#product_pictures_attributes_0_name').change(function(e){
    previewProductImages(e.target.files);
  });

  // show upload images popup
  $('.show-upload-images-popup').click(function(e){
    e.preventDefault();
    $('#upload-images-popup').modal('show');
  });

  // UPLOAD PRODUCTS CSV 
  $('.upload-csv-btn').click(function(){
    $('#upload-csv-popup').modal('show');
  });

  $('#csv_import_file').change(function(e){
    let files = e.target.files;
    let fileValidator = validCsvFile(files);
    if(fileValidator.isValid){
      $('#upload-csv-popup .modal-body').find('.file-errors').remove();
      uploadCSVFile(files);
    }else{
      document.getElementById('csv_import_file').value = "";
      $('#upload-csv-popup .modal-body').find('.file-errors').remove();
      $('#upload-csv-popup .modal-body').append('<ul class="file-errors" style="color: red;">'+fileValidator.errors.map(e => '<li>'+e+'</li>').join("")+'</ul>')
    }
  });


  $(document).on('click','.img-del-icon', function(){
    if(confirm("Are you sure to delete this image?")){
      if($(this).hasClass('new-obj')){
        $(this).parents('.col-md-4').remove();
      }else{
        $(this).parents('.p-img-container').hide();
        $(this).find("[type='checkbox']").prop('checked',true)
      }
    }
  });

});

function uploadCSVFile(files){
  $('#csv_import_file').attr('disabled', true);
  let url = 'YOUR URL HERE'
  let formData = new FormData()
  formData.append('csv_import[file]', files[0])
  $.ajax({
    url: "/admin/products/upload_csv",
    type: "POST",
    data: formData,
    processData: false,  // tell jQuery not to process the data
    contentType: false,  // tell jQuery not to set contentType
    success: function(res){
      $('#upload-csv-popup').modal('hide');
      $('#upload-csv-success-popup').modal('show');
    },
    error: function(xhr){
      document.getElementById('csv_import_file').value = "";
      $('#upload-csv-popup .modal-body').find('.file-errors').remove();
      $('#upload-csv-popup .modal-body').append('<ul class="file-errors" style="color: red;">'+[xhr.responseJSON.errors].map(e => '<li>'+e+'</li>').join("")+'</ul>')
      // hide any loading image
      $('#csv_import_file').attr('disabled', false);
    }
  });
}

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

function bindDragAndDropEvents(dropAreaId){
  let dropArea = document.getElementById(dropAreaId)
  ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false)
  })
  dropArea.addEventListener('drop', fileDropHandler, false)
}

function fileDropHandler(e){
  let dt = e.dataTransfer
  let files = dt.files;
  let fileValidator = validCsvFile(files);
  if(fileValidator.isValid){
    $('#upload-csv-popup .modal-body').find('.file-errors').remove();
    uploadCSVFile(files);
  }else{
    $('#upload-csv-popup .modal-body').find('.file-errors').remove();
    $('#upload-csv-popup .modal-body').append('<ul class="file-errors" style="color: red;">'+fileValidator.errors.map(e => '<li>'+e+'</li>').join("")+'</ul>')
  }
}

function validCsvFile(files){
  let allowedExtensions = /(\.csv)$/i;
  let errors = [];
  if(!allowedExtensions.exec(files[0].name)) {
    errors.push('Invalid file type, allowed type is .csv')
  }
  let size = (files[0].size/1024)/1024;

  if(size > 10){
    errors.push('File size should be less than 10MB');
  }
  return { errors: errors , isValid: !(errors.length > 0) }
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
  let dropArea = document.getElementById('upload-images-popup')
  dropArea.classList.add('highlight')
}

function unhighlight(e) {
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
  template +=      '<div class="img-del-icon new-obj">';
  template +=          '<span class="fas fa-trash-alt"></span>';
  template +=      '</div>';
  template +=  '</div>';
  template += '</div>';
  return template;
}


