// load all products related js here
$(document).ready(function(){
  bindResultPerPageOption();
  bindAndSortByEvent();
  bindFilterByEvents();
  bindRemoveFilterBy();
  let updatedProductIds = [];
  let productErrors = [];
  $(document).on({
    mouseenter: function () {
      $(this).parents('.prod-table-row').find('.yavolo-btn').removeClass('btn-danger');
    },
    mouseleave: function () {
      $(this).parents('.prod-table-row').find('.yavolo-btn').addClass('btn-danger');
    }
  }, ".icon-manage-Yavolo.yo-opacity");

  $('.editable').change(function(){
    updateFieldValue($(this).data('pid'),$(this).val(),$(this).data('action'));
  });

  bindAndLoadSellersSelectize()
  setSellerSearchMenuAndQueryName();

  // on bulk update click event
  $('.mark-bulk-update').change(function(){
    if($(this).is(':checked')){
      $('.prod-table-row').find('input:checkbox').prop('checked', true);
    }else{
      $('.prod-table-row').find('input:checkbox').prop('checked', false);
    }
  });

  $('.bulk-actions a.dropdown-item').click(function(e){
    e.preventDefault();
    if($('.prod-table-row input[type=checkbox]:checked').length > 0){
      $('.y-page-container').find('.alert').remove();
      $('.bulk-actions a.dropdown-item').removeClass('active');
      $(this).addClass('active');
      let action = $('.bulk-actions a.dropdown-item.active').data('bulkaction');
      if(['activate','deactivate','yavolo_enabled','yavolo_disabled','delete'].includes(action)){
        $('#seller-products-confirm').modal('show');
      }else{
        $('#product-new-value').val('');
        $('#bulk-update-form-modal').modal('show');
      }
    }else{
      showErrorsAlert(['You have not selected any products to update'])
    }
  })

  // to update status or yavolo status
   $('#yes-perform-action').click(function(e){
      e.preventDefault();
      $('#seller-products-confirm').modal('hide');
      updateBulkProducts($('.bulk-actions a.dropdown-item.active').data('bulkaction'));
    })
  // to update value like price , stock or discount
  $('#y-yes-bulk-update').click(function(e){
    e.preventDefault();
    let action = $('.bulk-actions a.dropdown-item.active').data('bulkaction');
    // $('#seller-products-confirm').modal('hide');
    if($('#product-new-value').val().length > 0){
      $('#product-new-value').parents('.form-group').find('small').remove();
      $('#product-new-value').parents('.form-group').removeClass('error-field')
      $('#bulk-update-form-modal').modal('hide');
      // show loader
      updateBulkProducts(action);
    }else{
      $('#product-new-value').parents('.form-group').find('small').remove();
      $('#product-new-value').parents('.form-group').addClass('error-field');
      $('#product-new-value').parents('.form-group').append('<small>Please enter a valid value.</small>')
    }
  });

  // on enable yavolo click
  $(document).on('click',".enable-yavolo-btn", function(e){
    e.preventDefault();
    $(".modal-body #yes-btn").attr('data-params', $(this).data('params'));
    $("#yes-btn").attr("href", "/"+$('#namespace').val()+"/products/enable_yavolo");
  });

  $(document).on('click',".disable-yavolo-btn", function(e){
    e.preventDefault();
    $(".modal-body #yes-btn").attr('data-params', $(this).data('params'));
    $("#yes-btn").attr("href", "/"+$('#namespace').val()+"/products/disable_yavolo");
  });

  $(document).on('click','.p-yavolo-disabled',function(e){
    e.preventDefault();
    if($(this).parents('.prod-table-row').find('.enable-yavolo-btn').length > 0 )
      $(this).parents('.prod-table-row').find('.enable-yavolo-btn').trigger('click');
  });

  $(document).on('click','.p-yavolo-enabled',function(e){
    e.preventDefault();
    if($(this).parents('.prod-table-row').find('.disable-yavolo-btn').length > 0 )
      $(this).parents('.prod-table-row').find('.disable-yavolo-btn').trigger('click');
  });

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
  bindDragAndDropPhotosEvents();
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


  // start img delete
  $(document).on('click','.img-del-icon', function(){
    $(this).addClass('mark-as-delete');
    $('#yes-no-product-delete-img-modal').modal('show');
  });

  $('#yes-delete-img').click(function(){
    if($('.mark-as-delete').length > 0){
      removeImage($('.mark-as-delete'));
      $('#yes-no-product-delete-img-modal').modal('hide');
    }
  });

  $('#yes-no-product-delete-img-modal').on('hidden.bs.modal', function () {
    $('.mark-as-delete').removeClass('mark-as-delete');
  });
  // end image delete


  $("#product_category").selectize({
    valueField: "id",
    labelField: "category_name",
    searchField: "category_name",
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
        url: "/"+$('#namespace').val()+"/categories/search_category",
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
    let productId = $('#product_id').val();
    let categoryId = $(this).val();
    getFilterGroupsOfBabyCategory(productId, categoryId);
  });


  // on product page load
  if($('#product_category').val() && $('#product_category').val().length > 0)
    getFilterGroupsOfBabyCategory($('#product_id').val(), $('#product_category').val());

});

function removeImage(ele){
  const filename =  ele.parents('.col-md-4').attr('data-file-name')
  if(ele.hasClass('new-obj')){
    ele.parents('.col-md-4').remove();
  }else{
    ele.parents('.p-img-container').hide();
    ele.find("[type='checkbox']").prop('checked',true)
  }
  let idx = ele.data('imgindex')+"";
  if(idx && $('#dupimg'+idx).length > 0){
    $('#dupimg'+idx).remove();
  }
  removeProductFromFileList(filename)
}

function bindResultPerPageOption(){
  $('.perpage-option').click(function(e){
    e.preventDefault();
    if($('#per_page').length > 0){
      $('#per_page').val($(this).data('per-page'));
    }else{
      $('#product_search').append('<input type="hidden" name="per_page" id="per_page">')
      $('#per_page').val($(this).data('per-page'));
    }
    $('form#product_search').submit();
  })
}
function bindAndSortByEvent(){
  $('.sortby-products').click(function(e){
    e.preventDefault();
    if($('#q_s').length > 0){
      $('#q_s').val($(this).data('sortby'));
    }else{
      $('#product_search').append('<input type="hidden" name="q[s]" id="q_s">')
      $('#q_s').val($(this).data('sortby'));
    }
    $('form#product_search').submit();
  });
}

function bindRemoveFilterBy(){
  $(document).on('click','.rm-filterby',function(){
    let removedFilter = $(this).data('yfilter');
    let statuses = [];
    if($('input.yp-statuses').length > 0 && $('input.yp-statuses').val().length > 0){
      $('input.yp-statuses').val().split(',').forEach(function(status){
        if(status!=removedFilter){
          statuses.push(status)
        }
      });
    }

    if (removedFilter=='yavolo_enabled'){
      $('#product_search').find('input.yp-yavolo_enabled').remove();
    }

    if(statuses.length > 0){
      if($('#product_search').find('input.yp-statuses').length > 0){
        $('#product_search').find('input.yp-statuses').val(statuses.join(','));
      }else{
        $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
        $('#product_search').find('input.yp-statuses').val(statuses.join(','));
      }
    }else{
      $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
      $('#product_search').find('input.yp-statuses').val('');
    }
    console.log(statuses);
    $('form#product_search').submit();
  });
}

function bindFilterByEvents(){
  $('.admin-filter-by').click(function(e){
    e.preventDefault();
    console.log($(this).data('status'));
    if($(this).hasClass('active')){
      $(this).removeClass('active');

      if($(this).data('status')=='yavolo_enabled')
        $('.yp-yavolo_enabled').remove();

    }else{
      $(this).addClass('active');
    }
    addFiltersAndFilterTags();
  });
}

function addFiltersAndFilterTags(){
  let html = [];
  let statuses = [];
  $('.admin-filter-by.active').each(function(){
  // html.push('<div>'+$(this).text()+'<span data-yfilter="'+$(this).data('status')+'"  class="rm-filterby">X</span></div>');
    if($(this).data('status')=='yavolo_enabled'){
      if($('#product_search').find('input.yp-yavolo_enabled').length == 0){
        $('#product_search').append('<input type="hidden" name="yavolo_enabled" class="yp-yavolo_enabled">')
        $('#product_search').find('input.yp-yavolo_enabled').val('1');
      }
    }else{
      statuses.push($(this).data('status'));
    }
  });
  // $('.filter-by-tags').html(html);
  console.log(statuses);

  if(statuses.length > 0){
    if($('#product_search').find('input.yp-statuses').length > 0){
      $('#product_search').find('input.yp-statuses').val(statuses.join(','));
    }else{
      $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
      $('#product_search').find('input.yp-statuses').val(statuses.join(','));
    }
  }else{
    $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
      $('#product_search').find('input.yp-statuses').val('');
  }
  $('form#product_search').submit();
}

function updateFieldValue(pid,val,action){
  $.ajax({
    url: "/sellers/products/"+pid+"/update_field",
    type: "POST",
    dataType: "json",
    data: {
      product: {
        id: pid,
        value: val,
        action: action
      }
    },
    error: function (xhr){
    },
    success: function (res){ 
    }
  });
}

function bindAndLoadSellersSelectize(){
  $("#search_seller_select").selectize({
    valueField: "id",
    labelField: "full_name",
    searchField: "full_name",
    render: {
      option: function (item, escape) {
        return (
          '<option value="'+item.id+'">'+item.full_name+'</option>'
        );
      },
    },
    load: function (query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: "/"+$('#namespace').val()+"/sellers/search",
        type: "GET",
        dataType: "json",
        data: {
          "q[email_or_first_name_or_last_name_cont]": query,
          "q[s]": "first_name asc",
          page_limit: 15
        },
        error: function () {
          callback();
        },
        success: function (res) {
          callback(res.sellers);
        },
      });
    },
  });
}

function getFilterGroupsOfBabyCategory(productId, selectedCategoryId){
  $.ajax({
    url: "/"+$('#namespace').val()+"/categories/"+selectedCategoryId+"/get_filter_groups.json?product_id="+productId,
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
      FGroup +=    '<select name="product[filter_in_category_ids][]" class="form-control filter-names" multiple >'
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
    url: "/"+$('#namespace').val()+"/products/upload_csv",
    type: "POST",
    data: formData,
    processData: false,  // tell jQuery not to process the data
    contentType: false,  // tell jQuery not to set contentType
    success: function(res){
      $('#upload-csv-popup').modal('hide');
      $('#upload-csv-success-popup').modal('show');
      $('#csv_import_file').attr('disabled', false);
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
    preveiwImagesTemplate.push(imageTemplate(URL.createObjectURL(files[i]),files[i].name));
    
  }
  if($('.product-photos-grid').length > 0){
    $('.product-photos-grid').append(preveiwImagesTemplate.join(""));
    $('.add-edit-product-photos').removeClass('col-lg-12').addClass('col-lg-8');
    $('.product-photos-section').show();
    $('#upload-images-popup').modal('hide');
  }
  let a = FileListItems(files, oldFiles)
  $("#product_pictures_attributes_0_name").prop("files",a)

}

var oldFiles = []

function FileListItems(files,oldFiles) {
  var b = new DataTransfer()
  var unique_names = []
  for (var i = 0, len = files.length; i<len; i++) {
    if(!unique_names.includes(files[i].name)){
      unique_names.push(files[i].name)
      b.items.add(files[i])
      oldFiles.push(files[i])
    }
  }

  for (var i = 0 , len = (files.length+oldFiles.length); i<oldFiles.length; i++){
    if(!unique_names.includes(oldFiles[i].name)){
      unique_names.push(oldFiles[i].name)
      b.items.add(oldFiles[i])
    }
  }
  return b.files
}

function removeProductFromFileList(filename){
  files = $("#product_pictures_attributes_0_name").prop("files")
  oldFiles = []
  let b = new DataTransfer()
  for (var i = 0, len = files.length; i<len; i++) {
    if(files[i].name != filename){
      b.items.add(files[i])
      oldFiles.push(files[i])
    }
  }
  $("#product_pictures_attributes_0_name").prop("files",b.files)
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
  let dropArea = document.getElementById('upload-images-popup');
  if(!dropArea) return;
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
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

function imageTemplate(path,filename){
  let template = "";
  template += `<div class="col-md-4 p-1" data-file-name="${filename}">`;
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

  $("#product_ean").parents('.form-group').find('small').remove();
  if($("#product_ean").val().length > 0){
    $("#product_ean").parents('.form-group').removeClass('error-field')
    $("#product_ean").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#product_ean").parents('.form-group').addClass('error-field')
    $("#product_ean").parents('.form-group').append('<small class="form-text">* Please enter a valid EAN.</small>')
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

  $("#product_category").parents('.form-group').find('small').remove();
  if($("#product_category").val().length > 0){
    $("#product_category").parents('.form-group').find(".selectize-input").removeClass('custom-border');
    $("#product_category").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#product_category").parents('.form-group').find(".selectize-input").addClass('custom-border');
    $("#product_category").parents('.form-group').append('<small class="form-text">* Category can\'t be blank</small>')
  }

  $("#search_seller_select").parents('.form-group').find('small').remove();
  if($("#search_seller_select").val().length > 0){
    $("#search_seller_select").parents('.form-group').find(".selectize-input").removeClass('custom-border');
    $("#search_seller_select").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#search_seller_select").parents('.form-group').find(".selectize-input").addClass('custom-border');
    $("#search_seller_select").parents('.form-group').append('<small class="form-text mt-0">* Seller can\'t be blank</small>')
  }

  return !has_errors.includes(true)
}


function updateBulkProducts(action){
  let productIds = []
  $('.prod-table-row input[type=checkbox]:checked').each(function(){ productIds.push($(this).val()) })
  if(productIds.length==0){
    showErrorsAlert(['Error: param value is missing.']);
    return false;
  }

  let dataParams = {action: action, product_ids: productIds}
  if(action =='update_price' || action =='update_stock' || action =='update_discount'){
    if($('#product-new-value').val().length > 0){
      dataParams.value = $('#product-new-value').val()
    }else{
      showErrorsAlert(['Error: param value is missing.']);
      return false;
    }
  }

  $.ajax({
    url: `/${$('#namespace').val()}/products/bulk_products_update?bulk_action=${action}`,
    method: 'POST',
    data: { 'product': dataParams },//$('#products-bulk-form').serialize(),
    success: function(res){
      updateProductsDom(res);
      showSuccessAlert('Products updated successfully');
      $('#product-new-value').val('');
      $('.bulk-actions a.dropdown-item').removeClass('active');
    },
    error: function(xhr){
      showErrorsAlert(xhr.responseJSON.errors);
      $('#product-new-value').val('');
    }
  })
}

function updateProductsDom(res){
  let action = $('.bulk-actions a.dropdown-item.active').data('bulkaction')
  let selectors = res.update_ids.map(id=> "#prod-id-"+id).join(',')
  if(action=='delete')
    $(selectors).remove();

  if(action=='update_price'){
    let price = parseFloat(res.value);
    if($('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.price-field').length > 0){
      $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.price-field').val(price.toFixed(2))
    }
    if($('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.price-box').length > 0){
      $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.price-box').html(price.toFixed(2))
    }
  }

  if(action=='update_stock'){
    let stock = parseInt(res.value)
    if($('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.stock-field').length > 0){
      $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.stock-field').val(stock)
    }
    if($('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.stock-box').length > 0){
      $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.stock-box').html(stock)
    }
  }

  if(action=='update_discount'){
    if($('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.discount-field').length > 0){
      $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.discount-field').val(res.value)
    }
    if($('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.discount-box').length > 0){
      $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.discount-box').html(res.value)
    }
  }

  if(action=='activate')
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('td.product-status').html('Active')

  if(action=='deactivate')
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('td.product-status').html('Inactive')

  if(action=='yavolo_enabled'){
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.enable-yavolo-btn').remove();
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').each(function(){
      let pid = $(this).attr('id').split('-')[$(this).attr('id').split('-').length-1];
      let disableBtn = '<a class="btn btn-sm btn-radius px-4 btn-secondary mb-2 w-100 btn-light-hvr btn-danger disable-yavolo-btn yavolo-btn" data-toggle="modal" data-target="#customConfirmModal" data-params="product[ids][]='+pid+'" id="pro-disableyavolo-btn-'+pid+'" href="#">Disable Yavolo</a>';
      $(this).find('input[type=checkbox]').prop('checked',false).trigger('change');
      $(this).find('.row-actions .enable-yavolo-btn').remove();
      if($(this).find('.row-actions .disable-yavolo-btn').length == 0){
        $(this).find('.row-actions').prepend(disableBtn);
        $(this).find('.icon-manage-Yavolo').removeClass('yo-opacity p-yavolo-disabled');
        $(this).find('.icon-manage-Yavolo').addClass('p-yavolo-enabled');
      }
    });
  }



  if(action=='yavolo_disabled'){
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').each(function(){
      let pid = $(this).attr('id').split('-')[$(this).attr('id').split('-').length-1];
      let enableBtn = '<a class="btn btn-sm btn-radius px-4 btn-secondary mb-2 w-100 btn-light-hvr btn-danger enable-yavolo-btn yavolo-btn" data-toggle="modal" data-target="#customConfirmModal" data-params="product[ids][]='+pid+'" id="pro-enyavolo-btn-'+pid+'" href="#">Enable Yavolo</a>';
      $(this).find('input[type=checkbox]').prop('checked',false).trigger('change');
      $(this).find('.row-actions .disable-yavolo-btn').remove();
      if($(this).find('.row-actions .enable-yavolo-btn').length == 0){
        $(this).find('.row-actions').prepend(enableBtn)
        $(this).find('.icon-manage-Yavolo').addClass('yo-opacity p-yavolo-disabled');
        $(this).find('.icon-manage-Yavolo').removeClass('p-yavolo-enabled');
      }
    })
  }
  $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('input[type=checkbox]').prop('checked',false).trigger('change')
}

window.showSuccessAlert = function(msg){
  $('.y-page-container').find('.alert').remove();
  let alertMsg = '<p class="flash-toast notice notice-msg">'+msg+'<span  class="notice-cross-icon" aria-hidden="true">&times;</span></p>'
  $('.y-page-container').prepend(alertMsg);
  $(".alert-success").fadeTo(2000, 500).slideUp(500, function(){
      $(".alert-success").slideUp(500);
  });
}
window.showErrorsAlert = function(errors){
  $('.y-page-container').find('.alert').remove();
  let alertErrors = '<div class="flash-toast alert alert-msg text-left"><ul>'+errors.map(e=>"<li>"+e+"</li>").join("")+'</ul><span class="notice-cross-icon" aria-hidden="true">&times;<span></div>';
  $('.y-page-container').prepend(alertErrors);
}

function setSellerSearchMenuAndQueryName(){
  $('.seller-products-filters a').click(function(e){
    e.preventDefault();
    let currentFilter = $(this).text().trim();
    let searchField = $('.seller-product-search-field');
    let filterType = $('#product-filter-type');
    $('.seller-products-filters a').removeClass('active');
    $(this).addClass('active')
    $('.current-search-filter').html(currentFilter+' <i class="fa fa-angle-down ml-2" aria-hidden="true"></i>');
    if(currentFilter=='Product Title'){
      searchField.attr('name', 'q[title_cont]');
      $('#csfn').val('title_cont');
      filterType.val('Product Title');
    }else if(currentFilter=='Brand'){
      searchField.attr('name', 'q[brand_cont]');
      $('#csfn').val('brand_cont');
      filterType.val('Brand');
    }else if(currentFilter=='SKU'){
      searchField.attr('name', 'q[sku_cont]');
      $('#csfn').val('sku_cont');
      filterType.val('SKU');
    }else if(currentFilter=='YAN'){
      searchField.attr('name', 'q[yan_cont]');
      $('#csfn').val('yan_cont');
      filterType.val('YAN');
    }else if(currentFilter=='EAN'){
      searchField.attr('name', 'q[ean_cont]');
      $('#csfn').val('ean_cont');
      filterType.val('EAN');
    }else{
      $('.current-search-filter').text('Search All');
      searchField.attr('name', 'q[title_or_brand_or_sku_or_yan_or_ean_cont]');
      $('#csfn').val('title_or_brand_or_sku_or_yan_or_ean_cont');
      filterType.val('Search All');
    }
  });
}
