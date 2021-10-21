// load all products related js here
$(document).ready(function(){
  // on product form submit event
  $('#product_form').submit(function(e){
    if(!validProductForm()){
      e.preventDefault();
      $([document.documentElement, document.body]).animate({
        scrollTop: $("#listing-details").offset().top
      }, 2000);
      return;
    }
  });

  productSearchByFilter();
  // bindDragAndDropPhotosEvents();
  if(document.getElementById('upload-csv-popup'))
    bindDragAndDropEvents('upload-csv-popup');

  $('#product_pictures_attributes_0_name').change(function(e){
    let imagesValidator = validProductImages(e.target.files);
    if(imagesValidator.isValid){
      $('.file-errors').html("")
      previewProductImages(e.target.files);
    }else{
      document.getElementById('product_pictures_attributes_0_name').value=''
      $('.file-errors').html("")
      $('.file-errors').html(imagesValidator.errors.map(e => '<li>'+e+'</li>').join(""))
      $('#upload-images-popup').modal('hide');
    }
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
      let idx = $(this).data('imgindex')+"";
      if(idx && $('#dupimg'+idx).length > 0){
        $('#dupimg'+idx).remove();
      }
    }
  });

  $("#product_category").selectize({
    valueField: "id",
    labelField: "category_name",
    searchField: "category_name",
    // options: [],
    // create: false,
    render: {
      option: function (item, escape) {
        return (
          '<option value="'+item.id+'">'+item.category_name+'</option>'
        );
      },
    },
    load: function (query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: "/admin/categories/search_category",
        type: "GET",
        dataType: "json",
        data: {
          q: query,
          page_limit: 10,
          apikey: "w82gs68n8m2gur98m6du5ugc",
        },
        error: function () {
          callback();
        },
        success: function (res) {
          callback(res.data);
        },
      });
    },
  });

  $('#product_category').change(function(){
    console.log($(this).val());
    let productId = $('#product_id').val();
    let categoryId = $(this).val();
    getFilterGroupsOfBabyCategory(productId, categoryId);
  });


  // on product page load
  if($('#product_category').val() && $('#product_category').val().length > 0)
    getFilterGroupsOfBabyCategory($('#product_id').val(), $('#product_category').val());

});

function getFilterGroupsOfBabyCategory(productId, selectedCategoryId){
  $.ajax({
    url: "/admin/categories/"+selectedCategoryId+"/get_filter_groups.json?product_id="+productId,
    type: "GET",
    success: function(res){
      renderCategoryFilterGroups(res)
    },
    error: function(){}
  })
}

function renderCategoryFilterGroups(res){
  let filterGroups = [];
  let filterInCategoryIds = res.data.filter_in_category_ids;

  if(res.data.filter_groups.length > 0){
    for(let i=0; i < res.data.filter_groups.length; i++){
      let FGroup = '';
      FGroup += '<div class="general-mrgn col-md-3 mt-0">'
      FGroup +=    '<label>'+res.data.filter_groups[i].filter_name+'</label>'
      FGroup +=    '<select name="product[filter_in_category_ids][]" class="form-control filter-names" multiple required>'
      if(res.data.filter_groups[i].filter_in_categories.length > 0){
        for(let j=0; j < res.data.filter_groups[i].filter_in_categories.length; j++){
          let finId = res.data.filter_groups[i].filter_in_categories[j].id
          FGroup +='<option '+(filterInCategoryIds.length > 0 && filterInCategoryIds.includes(finId) ? 'selected' : '' )+' value="'+finId+'">'+res.data.filter_groups[i].filter_in_categories[j].name+'</option>'
        }
      }
      FGroup +=    '</select>'
      FGroup += '</div>'

      filterGroups.push(FGroup)
    }
  }

  if(filterGroups.length > 0){
    $('#category-filter-section').html("")
    $('#category-filter-section').html(filterGroups.join(""))
  }else{
    $('#category-filter-section').html("").html("No Filter Groups found")
    $('#category-filter-section').append("<input class='finids' type='hidden' name='product[filter_in_category_ids][]'>")
  }
  $(".filter-names").selectize();
}



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

function validProductImages(files){
  let allowedExtensions = /(\.jpg|\.jpeg|\.png)$/i;
  let errors = [];

  for(let i=0; i< files.length; i++){
    if(!allowedExtensions.exec(files[i].name)) {
      errors.push('Invalid file type, allowed type is jpg, jpeg and png')
    }
    let size = (files[i].size/1024)/1024;
    if(size > 10){
      errors.push('File size should be less than 10MB');
    }
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


function productSearchByFilter(){
  var $productDropdown = $('.product-search-dropdown');
  var $productSearchField = $('.product-search-field');
  var $productFilterTypeField = $('#product-filter-type');
  $('#product-search-by-toggle a').click(function(e){
    var $currFilter = $(this).text().trim();
    e.preventDefault();
    $productDropdown.text($(this).text());
    if($currFilter === 'Product Title A-Z'){
      $productSearchField.attr('name', 'q[title_a_z_cont]');
      $productFilterTypeField.val('Product Title A-Z');
    }
    else if($currFilter === 'Product Title Z-A'){
      $productSearchField.attr('name', 'q[title_z_a_cont]');
      $productFilterTypeField.val('Product Title Z-A');
    }
    else if($currFilter === 'Price Low-High'){
      $productSearchField.attr('name', 'q[price_low_high_cont]');
      $productFilterTypeField.val('Price Low-High');
    }
    else if($currFilter === 'Price High-Low'){
      $productSearchField.attr('name', 'q[price_high_low_cont]');
      $productFilterTypeField.val('Price High-Low');
    }
    else if($currFilter === 'Brand'){
      $productSearchField.attr('name', 'q[brand_cont]');
      $productFilterTypeField.val('Brand');
    }
    else if($currFilter === 'SKU'){
      $productSearchField.attr('name', 'q[sku_cont]');
      $productFilterTypeField.val('SKU');
    }
    else if($currFilter === 'YAN'){
      $productSearchField.attr('name', 'q[yan_cont]');
      $productFilterTypeField.val('YAN');
    }
    else if($currFilter === 'EAN'){
      $productSearchField.attr('name', 'q[ean_cont]');
      $productFilterTypeField.val('EAN');
    }
    else {
      $productSearchField.attr('name', 'q[title_or_brand_or_sku_or_ean_or_yan_cont]');
      $productFilterTypeField.val('Search All');
    }
  });
}


function validProductForm(){
  let has_errors = []

  $("#product_title").parents('.form-group').find('small').remove();
  if($("#product_title").val().length > 0){
    $("#product_title").parents('.form-group').removeClass('error-field')
    $("#product_title").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#product_title").parents('.form-group').addClass('error-field')
    $("#product_title").parents('.form-group').append('<small class="form-text">Title can\'t be blank</small>')
  }

  $("#product_price").parents('.form-group').find('small').remove();
  if($("#product_price").val().length > 0){
    $("#product_price").parents('.form-group').removeClass('error-field')
    $("#product_price").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#product_price").parents('.form-group').addClass('error-field')
    $("#product_price").parents('.form-group').append('<small class="form-text">* Price can\'t be blank</small>')
  }

  $("#product_stock").parents('.form-group').find('small').remove();
  if($("#product_stock").val().length > 0){
    $("#product_stock").parents('.form-group').removeClass('error-field')
    $("#product_stock").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#product_stock").parents('.form-group').addClass('error-field')
    $("#product_stock").parents('.form-group').append('<small class="form-text">* Stock can\'t be blank</small>')
  }

  if($("[name='product[delivery_option_id]']:checked").length > 0){
    $('.d-option-id').hide();
  }else{
    has_errors.push(true)
    $('.d-option-id').show();
  }

  $("#product_condition").parents('.form-group').find('small').remove();
  if($('#product_condition').val().length > 0){
    $("#product_condition").parents('.form-group').removeClass('error-field')
    $("#product_condition").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#product_condition").parents('.form-group').addClass('error-field')
    $("#product_condition").parents('.form-group').append('<small class="form-text">* Condition can\'t be blank</small>')
  }

  $('#product_keywords').parents('.form-group').find('small').remove();
  if($('#product_keywords').val().length > 0){
    $('#product_keywords').parents('.form-group').removeClass('error-field')
    $('#product_keywords').parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $('#product_keywords').parents('.form-group').addClass('error-field')
    $('#product_keywords').parents('.form-group').append('<small class="form-text">* Keywords can\'t be blank</small>')
  }

  $('#product_description').parents('.form-group').find('small').remove();
  if(disEditor.getData().length>0){
    $('#product_description').parents('.form-group').removeClass('error-field')
    $('#product_description').parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $('#product_description').parents('.form-group').addClass('error-field')
    $('#product_description').parents('.form-group').append('<small class="form-text">* * Description can\'t be blank</small>')
  }
  return !has_errors.includes(true)
}
