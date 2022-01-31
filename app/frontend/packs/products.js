import 'select2'
import 'select2/dist/css/select2.css'
// load all products related js here
$(document).ready(function() {
  bindResultPerPageOption();
  bindAndSortByEvent();
  bindFilterByEvents();
  bindRemoveFilterBy();
  divAdjusterWidth();
  eanErrorRemoveBackend();
  disableEnterOnProductCreate();
  priceUpdateOnListing();
  productImageDelete();
  stockUpdateOnListing();
  discountUpdateOnListing();
  inputMaskCurrencyField();
  setYavoloSearchMenuAndQueryName()
  removeOrdersSearch();
  validateEAN();
  validateEANBeforeSubmission();
  setTimeout(function() { 
      $('.select2-selection.select2-selection--single').addClass('select2-custom-height');
  }, 500);
  $("#verify").click(function() {
    $('#information-modal').modal('show');
  });

  if ($(".grid-single-img").length >= 9) {
    $('.photo-btn').text('Edit Photos');
    $('.photo-btn').parent('.add-photo-inner').attr('title', 'You can add only 9 photos');
    $(".show-upload-images-popup").addClass('pointer-events-none');
  }

  $(document).on({
    mouseenter: function() {
      $(this).parents('.prod-table-row').find('.yavolo-btn').removeClass('btn-danger');
    },
    mouseleave: function() {
      $(this).parents('.prod-table-row').find('.yavolo-btn').addClass('btn-danger');
    }
  }, ".icon-manage-Yavolo.yo-opacity");

  $('.editable').change(function() {
    if ($(this).parents('.error-field').length < 1) {
      updateFieldValue($(this).data('pid'), $(this).val(), $(this).data('action'));
    }
  });

  bindAndLoadSellersSelect2()
  setSellerSearchMenuAndQueryName();

  $(document).on('click', ".product-photos-wrapper .img-star-icon", function() {
    const filename = $(this).parents('.col-md-4').attr('data-file-name');
    const featuredImageInput = $("#featured_image_input")
    const identificationType = $(this).parents('.col-md-4').attr('data-identification-type')
    const data = JSON.stringify({
      identifier: filename,
      identifier_type: identificationType
    })
    featuredImageInput.val(data)
    const previousFeaturedImage = $(".product-photos-wrapper .img-star-icon.featured");
    if (previousFeaturedImage.length) {
      previousFeaturedImage.removeClass("featured")
    }
    $(this).addClass("featured")
  })

  // on bulk update click event
  $('.mark-bulk-update').change(function() {
    if ($(this).is(':checked')) {
      $('.prod-table-row').find('input:checkbox').prop('checked', true);
    } else {
      $('.prod-table-row').find('input:checkbox').prop('checked', false);
    }
  });

  $(".multiple-products input").click(function() {
    if (!$(this).is(":checked")) {
      $(".mark-bulk-update").prop("checked", false);
    }
  });

  $('.bulk-actions a.dropdown-item').click(function(e) {
    e.preventDefault();
    if ($('.prod-table-row input[type=checkbox]:checked').length > 0) {
      $('.y-page-container').find('.alert').remove();
      $('.bulk-actions a.dropdown-item').removeClass('active');
      $(this).addClass('active');
      let action = $('.bulk-actions a.dropdown-item.active').data('bulkaction');
      if (['activate', 'deactivate', 'yavolo_enabled', 'yavolo_disabled', 'delete'].includes(action)) {
        $('#seller-products-confirm').modal('show');
      } else {
        $('#product-new-value').val('');
        $('#bulk-update-form-modal').modal('show');
      }
    } else {
      showErrorsAlert(['You have not selected any products to update'])
    }
  })

  // to update status or yavolo status
  $('#yes-perform-action').click(function(e) {
    e.preventDefault();
    $('#seller-products-confirm').modal('hide');
    updateBulkProducts($('.bulk-actions a.dropdown-item.active').data('bulkaction'));
  })
  // to update value like price , stock or discount
  $('#y-yes-bulk-update').click(function(e) {
    e.preventDefault();
    let action = $('.bulk-actions a.dropdown-item.active').data('bulkaction');
    // $('#seller-products-confirm').modal('hide');
    if ($('#product-new-value').val().length > 0) {
      $('#product-new-value').parents('.form-group').find('small').remove();
      $('#product-new-value').parents('.form-group').removeClass('error-field')
      $('#bulk-update-form-modal').modal('hide');
      // show loader
      updateBulkProducts(action);
    } else {
      $('#product-new-value').parents('.form-group').find('small').remove();
      $('#product-new-value').parents('.form-group').addClass('error-field');
      $('#product-new-value').parents('.form-group').append('<small class="clr">Please enter a valid value.</small>')
    }
  });

  // on enable yavolo click
  $(document).on('click', ".enable-yavolo-btn", function(e) {
    e.preventDefault();
    $(".modal-body #yes-btn").attr('data-params', $(this).data('params'));
    $("#yes-btn").attr("href", "/" + $('#namespace').val() + "/products/enable_yavolo");
  });

  $(document).on('click', ".disable-yavolo-btn", function(e) {
    e.preventDefault();
    $(".modal-body #yes-btn").attr('data-params', $(this).data('params'));
    $("#yes-btn").attr("href", "/" + $('#namespace').val() + "/products/disable_yavolo");
  });

  $(document).on('click', '.p-yavolo-disabled', function(e) {
    e.preventDefault();
    if ($(this).parents('.prod-table-row').find('.enable-yavolo-btn').length > 0)
      $(this).parents('.prod-table-row').find('.enable-yavolo-btn').trigger('click');
  });

  $(document).on('click', '.p-yavolo-enabled', function(e) {
    e.preventDefault();
    if ($(this).parents('.prod-table-row').find('.disable-yavolo-btn').length > 0)
      $(this).parents('.prod-table-row').find('.disable-yavolo-btn').trigger('click');
  });

  productSearchByFilter();
  bindDragAndDropPhotosEvents();
  if (document.getElementById('upload-csv-popup'))
    bindDragAndDropEvents('upload-csv-popup');

  $('#product_pictures_attributes_0_name').change(function(e) {
    let imagesValidator = validProductImages(e.target.files);
    if (imagesValidator.isValid) {
      $('.file-errors').html("")
      previewProductImages(e.target.files);
    } else {
      document.getElementById('product_pictures_attributes_0_name').value = ''
      $('#upload-images-popup').modal('hide');
    }
  });

  // show upload images popup
  $('.show-upload-images-popup').click(function(e) {
    e.preventDefault();
    $('#upload-images-popup').modal('show');
  });

  // UPLOAD PRODUCTS CSV 
  $('.upload-csv-btn').click(function() {
    $('#upload-csv-popup').modal('show');
  });

  $('#csv_import_file').change(function(e) {
    let files = e.target.files;
    let fileValidator = validCsvFile(files);
    if (fileValidator.isValid) {
      $('#upload-csv-popup .modal-body').find('.file-errors').remove();
      uploadCSVFile(files);
    } else {
      document.getElementById('csv_import_file').value = "";
      $('#upload-csv-popup .modal-body').find('.file-errors').remove();
    }
  });

  // start img delete
  $(document).on('click', '.img-del-icon', function() {
    $(this).addClass('mark-as-delete');
    $('#yes-no-product-delete-img-modal').modal('show');
  });

  $('.grid-single-img').click(function() {
    if ($('.grid-single-img').length < 1) {
      $('.add-edit-product-photos').removeClass('col-lg-8').addClass('col-lg-12');
    }
  })

  function productImageDelete() {
    let updatedProductIds = [];
    let productErrors = [];
    $('#yes-delete-img').click(function() {
      if ($('.mark-as-delete').length > 0) {
        removeImage($('.mark-as-delete'));
        // divAdjusterWidth();
        $('#yes-no-product-delete-img-modal').modal('hide');
        let total_images = $(".grid-single-img").length
        var markAsDel = $(".grid-single-img .mark-as-delete").length
        if (total_images < 1) {
          $('.icon-help-style').hide();
        }
        if (total_images - markAsDel < 9) {
          $('.photo-btn').text('Add Photos');
          $('.photo-btn').parent('.add-photo-inner').attr('title', '');
          $('.photo-btn').removeClass('pointer-events-none')
        }
      }
    });
  }

  $('#yes-no-product-delete-img-modal').on('hidden.bs.modal', function() {

    $('.mark-as-delete').removeClass('mark-as-delete');

    divAdjusterWidth();
  });
  // end image delete

  bindAndLoadBabyCategoriesSelect2()

  $('#product_category').change(function() {
    let productId = $('#product_id').val();
    let categoryId = $(this).val();
    getFilterGroupsOfBabyCategory(productId, categoryId);
  });


  // on product page load
  if ($('#product_category').val() && $('#product_category').val().length > 0)
    getFilterGroupsOfBabyCategory($('#product_id').val(), $('#product_category').val());

  if ($('#product_description').length) {
    ClassicEditor
      .create(document.querySelector('#product_description'), {
        toolbar: ['bold', 'italic', '|', 'bulletedList', 'numberedList']
      })
      .then(newEditor => {
        product_description_editor = newEditor;
        product_description_editor.model.document.on('change:data', () => {
          $('#product_description').val(product_description_editor.getData().trim());
          $('#product_description').trigger('change');
        });
      })
      .catch(error => {
        console.error(error);
      });
  }

  if ($('#product_google_shopping_attributes_description').length) {
    ClassicEditor.create(document.querySelector('#product_google_shopping_attributes_description'), {
      toolbar: ['bold', 'italic', '|', 'bulletedList', 'numberedList']
    }).catch(error => {
      console.error(error);
    });
  }
  if ($('#product_seo_content_attributes_description').length) {
    ClassicEditor.create(document.querySelector('#product_seo_content_attributes_description'), {
      toolbar: ['bold', 'italic', '|', 'bulletedList', 'numberedList']
    }).catch(error => {
      console.error(error);
    });
  }
  validateProductForm();

  $(".yavolo-discount-dropdown a:not(.custom-value):not(.yavolo-discount-custom-input)").click(function(e) {
    e.preventDefault();
    const value = $(this).attr('data-value')
    const title = `${value} %` || "Custom"
    $(".yavolo-discount-dropdown-title").html(title)
    $(".yavolo-discount-hidden-input").val(value)
    yavoloDiscountValidation();
    $(".yavolo-discount-custom-input").addClass("d-none")
    $(".yavolo-discount-dropdown .custom-value").removeClass("active")
  })

  $(".yavolo-discount-dropdown .custom-value").click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(".yavolo-discount-dropdown-title").html("Custom")
    $(".yavolo-discount-custom-input").val("").removeClass("d-none")
    $(this).addClass("active")
    $(".yavolo-discount-hidden-input").val($('#customInputValue').val())
    yavoloDiscountValidation();
  })

  $("customInputValue").attr({
    "max": 100,
    "min": 2.5
  });

  $(".yavolo-discount-custom-input").click(function(e) {
    e.preventDefault();
    e.stopPropagation();
  })

  $(".yavolo-discount-custom-input input").change(function(e) {
    const value = $(this).val()
    if(!value) return
    $('#customInputValue').attr('value', value)
    $(".yavolo-discount-hidden-input").val(value)
    yavoloDiscountValidation();
  })

});

let product_description_editor;

function disableEnterOnProductCreate() {
  $('#product_form').on('keyup keypress', function(e) {
    var keyCode = e.keyCode || e.which;
    if (keyCode === 13) {
      e.preventDefault();
      return false;
    }
  });
}

function removeImage(ele) {
  let count = 1;
  const filename = ele.parents('.col-md-4').attr('data-file-name')
  let total_remove = $('.product-photos-grid > .remove').length;
  let current_stack = $('.product-photos-grid > .p-1').length;
  let total_images = $(".grid-single-img").length
  if (ele.hasClass('new-obj')) {
    ele.parents('.col-md-4').remove();
    total_remove = total_remove + count;
  } else {
    ele.parents('.p-img-container').hide();
    ele.parents('.p-img-container').addClass('remove');
    ele.find("[type='checkbox']").prop('checked', true)
    total_remove = total_remove + count;
    if (total_images == total_remove){
        $('.icon-help-style').hide();
    }
    if(total_images - total_remove < 9){
      $('.photo-btn').text('Add Photos');
      $('.photo-btn').parent('.add-photo-inner').attr('title', '');
      $('.photo-btn').removeClass('pointer-events-none')
    }
  }
  const featuredImageInput = $("#featured_image_input")
  if (featuredImageInput.val()) {
    const identifier = JSON.parse(featuredImageInput.val()).identifier
    if (identifier == filename) {
      featuredImageInput.val('')
    }
  }

  if (current_stack === total_remove) $('.photo-btn').text('Add Photos');
  let idx = ele.data('imgindex') + "";
  if (idx && $('#dupimg' + idx).length > 0) {
    $('#dupimg' + idx).remove();
  }
  removeProductFromFileList(filename)
}

function bindResultPerPageOption() {
  $('.perpage-option').click(function(e) {
    e.preventDefault();
    if ($('#per_page').length > 0) {
      $('#per_page').val($(this).data('per-page'));
    } else {
      $('#product_search').append('<input type="hidden" name="per_page" id="per_page">')
      $('#per_page').val($(this).data('per-page'));
    }
    $('form#product_search').submit();
  })
}

function bindAndSortByEvent() {

  $('.sortby-products').click(function(e) {
    e.preventDefault();

    if ($('#q_s').length === 0) {
      $('#product_search').append('<input type="hidden" name="q[s]" id="q_s">')
    }
    assignValueToProductSortFilterInput($(this).data('sortby'))
    $('form#product_search').submit();
  });
}

function assignValueToProductSortFilterInput(currentValue) {
  const title_asc = "title asc";
  const title_desc = "title desc";
  const price_desc = "price desc";
  const price_asc = "price asc";
  const inputVal = $('#q_s').val()
  let valueArray = []
  try {
    valueArray = JSON.parse(inputVal.split(","))
  } catch (e) {}

  if (currentValue === title_asc && valueArray.includes(title_desc)) {
    valueArray = valueArray.filter(i => i !== title_desc || i.strip == "")
  } else if (currentValue === title_desc && valueArray.includes(title_asc)) {
    valueArray = valueArray.filter(i => i !== title_asc || i.strip == "")
  } else if (currentValue === price_desc && valueArray.includes(price_asc)) {
    valueArray = valueArray.filter(i => i !== price_asc || i.strip == "")
  } else if (currentValue === price_asc && valueArray.includes(price_desc)) {
    valueArray = valueArray.filter(i => i !== price_desc || i.strip == "")
  }
  valueArray.push(currentValue)
  $('#q_s').val(JSON.stringify(valueArray));
}


function bindRemoveFilterBy() {
  $(document).on('click', '.rm-filterby', function() {
    let removedFilter = $(this).data('yfilter');

    bindRemoveFilterByStatusesForProduct(removedFilter)
    bindRemoveFilterBySortOrderForProduct(removedFilter)

    if (removedFilter == 'yavolo_enabled') {
      $('#product_search').find('input.yp-yavolo_enabled').remove();
    }
    $('form#product_search').submit();
  });
}

function bindRemoveFilterBySortOrderForProduct(removedFilter) {
  const inputVal = $('#q_s').val()
  let valueArray = []
  try {
    valueArray = JSON.parse(inputVal.split(","))
  } catch (e) {}
  valueArray = valueArray.filter(i => i !== removedFilter)
  $('#q_s').val(JSON.stringify(valueArray));
}

function bindRemoveFilterByStatusesForProduct(removedFilter) {
  let statuses = [];
  if ($('input.yp-statuses').length > 0 && $('input.yp-statuses').val().length > 0) {
    $('input.yp-statuses').val().split(',').forEach(function(status) {
      if (status != removedFilter) {
        statuses.push(status)
      }
    });
  }
  if (statuses.length > 0) {
    if ($('#product_search').find('input.yp-statuses').length > 0) {
      $('#product_search').find('input.yp-statuses').val(statuses.join(','));
    } else {
      $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
      $('#product_search').find('input.yp-statuses').val(statuses.join(','));
    }
  } else {
    $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
    $('#product_search').find('input.yp-statuses').val('');
  }
}

function bindFilterByEvents() {
  $('.admin-filter-by').click(function(e) {
    e.preventDefault();
    console.log($(this).data('status'));
    if ($(this).hasClass('active')) {
      $(this).removeClass('active');

      if ($(this).data('status') == 'yavolo_enabled')
        $('.yp-yavolo_enabled').remove();
    } else {
      $(this).addClass('active');
    }
    addFiltersAndFilterTags();
  });
}

function addFiltersAndFilterTags() {
  let html = [];
  let statuses = [];
  $('.admin-filter-by.active').each(function() {
    // html.push('<div>'+$(this).text()+'<span data-yfilter="'+$(this).data('status')+'"  class="rm-filterby">X</span></div>');
    if ($(this).data('status') == 'yavolo_enabled') {
      if ($('#product_search').find('input.yp-yavolo_enabled').length == 0) {
        $('#product_search').append('<input type="hidden" name="yavolo_enabled" class="yp-yavolo_enabled">')
        $('#product_search').find('input.yp-yavolo_enabled').val('1');
      }
    } else {
      statuses.push($(this).data('status'));
    }
  });
  // $('.filter-by-tags').html(html);
  console.log(statuses);

  if (statuses.length > 0) {
    if ($('#product_search').find('input.yp-statuses').length > 0) {
      $('#product_search').find('input.yp-statuses').val(statuses.join(','));
    } else {
      $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
      $('#product_search').find('input.yp-statuses').val(statuses.join(','));
    }
  } else {
    $('#product_search').append('<input type="hidden" name="statuses" class="yp-statuses">')
    $('#product_search').find('input.yp-statuses').val('');
  }
  $('form#product_search').submit();
}

function updateFieldValue(pid, val, action) {
  $.ajax({
    url: "/sellers/products/" + pid + "/update_field",
    type: "POST",
    dataType: "json",
    data: {
      product: {
        id: pid,
        value: val,
        action: action
      }
    },
    error: function(xhr) {
      displayNoticeMessage(xhr.responseJSON.errors[0])
    },
    success: function(res) {
      displayNoticeMessage(res.msg)
    }
  });
}

function bindAndLoadBabyCategoriesSelect2() {
  $('#product_category').select2({
    theme: 'bootstrap4',
    ajax: {
      url: "/" + $('#namespace').val() + "/categories/search_category",
      type: 'GET',
      dataType: 'json',
      delay: 250,
      data: function(params) {
        return {
          q: params.term,
          page: params.page || 1
        };
      },
      processResults: function(data, params) {
        params.page = params.page || 1;
        return {
          results: $.map(data.categories, function(e) {
            return {
              id: e.id,
              text: e.category_name
            }
          }),
          pagination: {
            more: (params.page * 10) < data.total_count
          }
        };
      },
      cache: true
    },
    placeholder: 'Search a baby category'
  });
}

function bindAndLoadSellersSelect2() {
  $('#search_seller_select').select2({
    theme: 'bootstrap4',
    ajax: {
      url: "/" + $('#namespace').val() + "/sellers/search",
      type: 'GET',
      dataType: 'json',
      delay: 250,
      data: function(params) {
        return {
          "q[name_cont]": params.term,
          "q[s]": "name asc",
          page: params.page || 1
        };
      },
      processResults: function(data, params) {
        params.page = params.page || 10;
        return {
          results: $.map(data.sellers,function(e){ return {id: e.seller_id, text: e.name}}),
          pagination: {
            more: (params.page * 10) < data.total_count
          }
        };
      },
      cache: true
    },
    placeholder: 'Search for a seller'
  });
}


function getFilterGroupsOfBabyCategory(productId, selectedCategoryId) {
  $.ajax({
    url: "/" + $('#namespace').val() + "/categories/" + selectedCategoryId + "/get_filter_groups.json?product_id=" + productId,
    type: "GET",
    success: function(res) {
      renderCategoryFilterGroups(res)
    },
    error: function() {}
  })
}

function renderCategoryFilterGroups(res) {
  let filterGroups = [];
  let filterInCategoryIds = res.data.filter_in_category_ids;

  if (res.data.filter_groups.length > 0) {
    for (let i = 0; i < res.data.filter_groups.length; i++) {
      let FGroup = '';
      FGroup += '<div class="general-mrgn col-md-3 mt-0">'
      FGroup += '<label>' + res.data.filter_groups[i].filter_name + '</label>'
      FGroup += '<select name="product[filter_in_category_ids][]" class="form-control filter-names" multiple >'
      if (res.data.filter_groups[i].filter_in_categories.length > 0) {
        for (let j = 0; j < res.data.filter_groups[i].filter_in_categories.length; j++) {
          let finId = res.data.filter_groups[i].filter_in_categories[j].id
          FGroup += '<option ' + (filterInCategoryIds.length > 0 && filterInCategoryIds.includes(finId) ? 'selected' : '') + ' value="' + finId + '">' + res.data.filter_groups[i].filter_in_categories[j].name + '</option>'
        }
      }
      FGroup += '</select>'
      FGroup += '</div>'

      filterGroups.push(FGroup)
    }
  }

  if (filterGroups.length > 0) {
    $('#category-filter-section').html("")
    $('#category-filter-section').html(filterGroups.join(""))
  } else {
    $('#category-filter-section').html("").html("No Filter Groups found")
    $('#category-filter-section').append("<input class='finids' type='hidden' name='product[filter_in_category_ids][]'>")
  }
  $(".filter-names").select2();
}



function uploadCSVFile(files) {
  $('#csv_import_file').attr('disabled', true);
  let url = 'YOUR URL HERE'
  let formData = new FormData()
  formData.append('csv_import[file]', files[0])
  formData.append('product_status', location.search.substr(1).split("&")[0].split("=")[1])
  $.ajax({
    url: "/" + $('#namespace').val() + "/products/upload_csv",
    type: "POST",
    data: formData,
    processData: false, // tell jQuery not to process the data
    contentType: false, // tell jQuery not to set contentType
    success: function(res) {
      $('#upload-csv-popup').modal('hide');
      $('#upload-csv-success-popup').modal('show');
      $('#csv_import_file').attr('disabled', false);
    },
    error: function(xhr) {
      document.getElementById('csv_import_file').value = "";
      $('#upload-csv-popup .modal-body').find('.file-errors').remove();
      $('#upload-csv-popup .modal-body').append('<ul class="file-errors" style="color: red;">' + [xhr.responseJSON.errors].map(e => '<li>' + e + '</li>').join("") + '</ul>')
      // hide any loading image
      $('#csv_import_file').attr('disabled', false);
    }
  });
}

function previewProductImages(files) {
  var fileList = Array.from(files)
  let currentPhotos = 9 - $('.product-photos-grid').find('.grid-single-img').length;
  if (currentPhotos > 0 && currentPhotos < 9) {
    for (var i = fileList.length; i > 0; i--) {
      if (i > currentPhotos) {
        fileList.splice(-1);
      }
    }
  }
  let preveiwImagesTemplate = [];
  for (let i = 0; i < fileList.length; i++) {
    if (i < 9) {
      preveiwImagesTemplate.push(imageTemplate(URL.createObjectURL(fileList[i]), fileList[i].name));
      $('.icon-help-style').show();
    } else {
      break;
    }

  }

  let current_files = $('.product-photos-grid > .p-1').length;
  let new_files = files.length;
  let total_images = current_files + new_files;
  if (total_images >= 9 || current_files >= 9 ) {
    $('.photo-btn').text('Edit Photos');
    $('.photo-btn').parent('.add-photo-inner').attr('title', 'You can add only 9 photos');
    $('.photo-btn').addClass('pointer-events-none')
  }

  if ($('.product-photos-grid').length > 0) {
    $('.product-photos-grid').append(preveiwImagesTemplate.join(""));
    $('.add-edit-product-photos').removeClass('col-lg-12').addClass('col-lg-8');
    $('.product-photos-section').show();
    $('#upload-images-popup').modal('hide');
  }
  let a = FileListItems(files, oldFiles)
  $("#product_pictures_attributes_0_name").prop("files", a)

}

var oldFiles = []

function FileListItems(files, oldFiles) {
  var b = new DataTransfer()
  var unique_names = []
  for (var i = 0, len = files.length; i < len; i++) {
    if (i < 9) {
      if (!unique_names.includes(files[i].name)) {
        unique_names.push(files[i].name)
        b.items.add(files[i])
        oldFiles.push(files[i])
      }
    } else {
      break;
    }
  }

  for (var i = 0, len = (files.length + oldFiles.length); i < oldFiles.length; i++) {
    if (i < 9) {
      if (!unique_names.includes(oldFiles[i].name)) {
        unique_names.push(oldFiles[i].name)
        b.items.add(oldFiles[i])
      }
    } else {
      break;
    }
  }
  return b.files
}

function removeProductFromFileList(filename) {
  var files = $("#product_pictures_attributes_0_name").prop("files")
  oldFiles = []
  let b = new DataTransfer()
  for (var i = 0, len = files.length; i < len; i++) {
    if (files[i].name != filename) {
      b.items.add(files[i])
      oldFiles.push(files[i])
    }
  }
  $("#product_pictures_attributes_0_name").prop("files", b.files)
}

function bindDragAndDropEvents(dropAreaId) {
  let dropArea = document.getElementById(dropAreaId);
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false)
  })
  dropArea.addEventListener('drop', fileDropHandler, false)
}

function fileDropHandler(e) {
  let dt = e.dataTransfer
  let files = dt.files;
  let fileValidator = validCsvFile(files);
  if (fileValidator.isValid) {
    $('#upload-csv-popup .modal-body').find('.file-errors').remove();
    uploadCSVFile(files);
  } else {
    $('#upload-csv-popup .modal-body').find('.file-errors').remove();
  }
}

function validCsvFile(files) {
  let allowedExtensions = /(\.csv)$/i;
  let has_error = false;
  if (!allowedExtensions.exec(files[0].name)) {
    displayNoticeMessage("Invalid file type, allowed type is .csv")
    has_error = true;
  }
  let size = (files[0].size / 1024) / 1024;

  if (size > 10) {
    displayNoticeMessage("File size should be less than 10MB")
    has_error = true;
  }
  return {
    isValid: !has_error
  }
}

function validProductImages(files) {
  let allowedExtensions = /(\.jpg|\.jpeg|\.png)$/i;
  let has_error = false;

  for (let i = 0; i < files.length; i++) {
    if (!allowedExtensions.exec(files[i].name)) {
      displayNoticeMessage("Invalid file type, allowed type is jpg, jpeg and png")
      has_error = true;
    }
    let size = (files[i].size / 1024) / 1024;
    if (size > 10) {
      displayNoticeMessage("File size should be less than 10MB")
      has_error = true;
    }
  }
  return {
    isValid: !has_error
  }
}

function bindDragAndDropPhotosEvents() {
  let dropArea = document.getElementById('upload-images-popup');
  if (!dropArea) return;
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false)
  })

  ;
  ['dragenter', 'dragover'].forEach(eventName => {
    dropArea.addEventListener(eventName, highlight, false)
  })

  ;
  ['dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, unhighlight, false)
  })

  dropArea.addEventListener('drop', handleDrop, false)

}

function preventDefaults(e) {
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

function imageTemplate(path, filename) {
  let template = "";
  template += `<div class="col-md-4 p-1" data-file-name="${filename}" data-identification-type="name">`;
  template += '<div class="grid-single-img">';
  template += '<span>';
  template += '<img src="' + path + '" alt="">';
  template += '</span>';

  // Added this condition because for bundle product we don't need to show featured image icon
  if (window.location.pathname.includes("/admin/yavolos/manual_bundles") === false) {
    template += '<div class="img-star-icon">';
    template += '<span class="icon-star-empty">\n' +
      '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-star" viewBox="0 0 16 16">\n' +
      '<path d="M2.866 14.85c-.078.444.36.791.746.593l4.39-2.256 4.389 2.256c.386.198.824-.149.746-.592l-.83-4.73 3.522-3.356c.33-.314.16-.888-.282-.95l-4.898-.696L8.465.792a.513.513 0 0 0-.927 0L5.354 5.12l-4.898.696c-.441.062-.612.636-.283.95l3.523 3.356-.83 4.73zm4.905-2.767-3.686 1.894.694-3.957a.565.565 0 0 0-.163-.505L1.71 6.745l4.052-.576a.525.525 0 0 0 .393-.288L8 2.223l1.847 3.658a.525.525 0 0 0 .393.288l4.052.575-2.906 2.77a.565.565 0 0 0-.163.506l.694 3.957-3.686-1.894a.503.503 0 0 0-.461 0z"/>\n' +
      '</svg>\n' +
      '</span>';
    template += '</div>';
  }
  template += '<div class="img-del-icon new-obj">';
  template += '<span class="fas fa-trash-alt"></span>';
  template += '</div>';
  template += '</div>';
  template += '</div>';
  return template;
}


function productSearchByFilter() {

  var $productDropdown = $('.product-search-dropdown');
  var $productSearchField = $('.product-search-field');
  var $productFilterTypeField = $('#product-filter-type');
  $('#product-search-by-toggle a').click(function(e) {
    var $currFilter = $(this).text().trim();
    e.preventDefault();
    $productDropdown.text($(this).text());
    if ($currFilter === 'Product Title A-Z') {
      $productSearchField.attr('name', 'q[title_a_z_cont]');
      $productFilterTypeField.val('Product Title A-Z');
    } else if ($currFilter === 'Product Title Z-A') {
      $productSearchField.attr('name', 'q[title_z_a_cont]');
      $productFilterTypeField.val('Product Title Z-A');
    } else if ($currFilter === 'Price Low-High') {
      $productSearchField.attr('name', 'q[price_low_high_cont]');
      $productFilterTypeField.val('Price Low-High');
    } else if ($currFilter === 'Price High-Low') {
      $productSearchField.attr('name', 'q[price_high_low_cont]');
      $productFilterTypeField.val('Price High-Low');
    } else if ($currFilter === 'Brand') {
      $productSearchField.attr('name', 'q[brand_cont]');
      $productFilterTypeField.val('Brand');
    } else if ($currFilter === 'SKU') {
      $productSearchField.attr('name', 'q[sku_cont]');
      $productFilterTypeField.val('SKU');
    } else if ($currFilter === 'YAN') {
      $productSearchField.attr('name', 'q[yan_cont]');
      $productFilterTypeField.val('YAN');
    } else if ($currFilter === 'EAN') {
      $productSearchField.attr('name', 'q[ean_cont]');
      $productFilterTypeField.val('EAN');
    } else {
      $productSearchField.attr('name', 'q[title_or_brand_or_sku_or_ean_or_yan_cont]');
      $productFilterTypeField.val('Search All');
    }
  });
}

function updateBulkProducts(action) {
  let productIds = []
  $('.prod-table-row input[type=checkbox]:checked').each(function() {
    productIds.push($(this).val())
  })
  if (productIds.length == 0) {
    showErrorsAlert(['Error: param value is missing.']);
    return false;
  }

  let dataParams = {
    action: action,
    product_ids: productIds
  }
  if (action == 'update_price' || action == 'update_stock' || action == 'update_discount') {
    if ($('#product-new-value').val().length > 0) {
      dataParams.value = $('#product-new-value').val()
      $("input:checkbox").not(this).prop("checked", false);
    } else {
      showErrorsAlert(['Error: param value is missing.']);
      return false;
    }
  }

  $.ajax({
    url: `/${$('#namespace').val()}/products/bulk_products_update?bulk_action=${action}`,
    method: 'POST',
    data: {
      'product': dataParams
    }, //$('#products-bulk-form').serialize(),
    success: function(res) {
      updateProductsDom(res);
      displayNoticeMessage('Products updated successfully');
      $('#product-new-value').val('');
      $('.bulk-actions a.dropdown-item').removeClass('active');
    },
    error: function(xhr) {
      showErrorsAlert(xhr.responseJSON.errors);
      $('#product-new-value').val('');
    },
    complete: function() {
      $(".mark-bulk-update").prop('checked', false)
    }
  })
}

function updateProductsDom(res) {
  var $prodRow = $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row')
  let action = $('.bulk-actions a.dropdown-item.active').data('bulkaction')
  let selectors = res.update_ids.map(id=> "#prod-id-"+id).join(',')
  if(action=='delete') {
    location.reload();
  }
  if(action=='update_price'){
    let price = parseFloat(res.value);
    var classNameOfAction = ".price-field, .price-box"
    updateBulkActions(res, classNameOfAction, "£" + price)
    if ($prodRow.find('.price-field').length > 0) {
      $prodRow.find('.price-field').val(price.toFixed(2))
    }
    if ($prodRow.find('.price-box').length > 0) {
      $prodRow.find('.price-box').html(price.toFixed(2))
    }
  }

  if (action == 'update_stock') {
    let stock = parseInt(res.value)
    var classNameOfAction = ".stock-field, .stock-box"
    stockUpdateOnListing();
    updateBulkActions(res, classNameOfAction, stock)
    if (($prodRow.find('.stock-field').length > 0) && ($prodRow.find('.stock-field').length < 10000)) {
      $prodRow.find('.stock-field').val(stock)
    }
    if ($prodRow.find('.stock-box').length > 0) {
      $prodRow.find('.stock-box').html(stock)
    }
  }

  if (action == 'update_discount') {
    var value = res.value
    let discount = parseFloat(res.value)
    var classNameOfAction = ".discount-field, .discount-box"
    updateBulkActions(res, classNameOfAction, discount)
    if ($prodRow.find('.discount-field').length > 0) {
      $prodRow.find('.discount-field').val(res.value)
    }
    if ($prodRow.find('.discount-box').length > 0) {
      $prodRow.find('.discount-box').html(res.value)
    }
  }

  if (action == 'activate')
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('td.product-status').html('Active')

  if (action == 'deactivate')
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('td.product-status').html('Inactive')

  if (action == 'yavolo_enabled') {
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('.enable-yavolo-btn').remove();
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').each(function() {
      let pid = $(this).attr('id').split('-')[$(this).attr('id').split('-').length - 1];
      let disableBtn = '<a class="btn btn-sm btn-radius px-4 btn-secondary mb-2 w-100 btn-light-hvr btn-danger disable-yavolo-btn yavolo-btn" data-toggle="modal" data-target="#customConfirmModal" data-params="product[ids][]=' + pid + '" id="pro-disableyavolo-btn-' + pid + '" href="#">Disable Yavolo</a>';
      $(this).find('input[type=checkbox]').prop('checked', false).trigger('change');
      $(this).find('.row-actions .enable-yavolo-btn').remove();
      if ($(this).find('.row-actions .disable-yavolo-btn').length == 0) {
        $(this).find('.row-actions').prepend(disableBtn);
        $(this).find('.icon-manage-Yavolo').removeClass('yo-opacity p-yavolo-disabled');
        $(this).find('.icon-manage-Yavolo').addClass('p-yavolo-enabled');
      }
    });
    $("input:checkbox").not(this).prop("checked", false);
  }

  if (action == 'yavolo_disabled') {
    $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').each(function() {
      let pid = $(this).attr('id').split('-')[$(this).attr('id').split('-').length - 1];
      let enableBtn = '<a class="btn btn-sm btn-radius px-4 btn-secondary mb-2 w-100 btn-light-hvr btn-danger enable-yavolo-btn yavolo-btn" data-toggle="modal" data-target="#customConfirmModal" data-params="product[ids][]=' + pid + '" id="pro-enyavolo-btn-' + pid + '" href="#">Enable Yavolo</a>';
      $(this).find('input[type=checkbox]').prop('checked', false).trigger('change');
      $(this).find('.row-actions .disable-yavolo-btn').remove();
      if ($(this).find('.row-actions .enable-yavolo-btn').length == 0) {
        $(this).find('.row-actions').prepend(enableBtn)
        $(this).find('.icon-manage-Yavolo').addClass('yo-opacity p-yavolo-disabled');
        $(this).find('.icon-manage-Yavolo').removeClass('p-yavolo-enabled');
      }
    })
  }
  $('.prod-table-row input[type=checkbox]:checked').parents('.prod-table-row').find('input[type=checkbox]').prop('checked', false).trigger('change')
  $("input:checkbox").not(this).prop("checked", false);
}

window.showSuccessAlert = function(msg) {
  $('.y-page-container').find('.alert').remove();
  let alertMsg = '<p class="flash-toast notice notice-msg">' + msg + '<span  class="notice-cross-icon" aria-hidden="true">&times;</span></p>'
  $('.y-page-container').prepend(alertMsg);
  $(".alert-success").fadeTo(2000, 500).slideUp(500, function() {
    $(".alert-success").slideUp(500);
  });
}
window.showErrorsAlert = function(errors) {
  $('.y-page-container').find('.alert').remove();
  let alertErrors = '<div class="flash-toast alert alert-msg text-left" id="product-flash-notice"><ul>' + errors.map(e => "<li>" + e + "</li>").join("") + '</ul><span class="notice-cross-icon" aria-hidden="true">&times;<span></div>';
  $('.y-page-container').prepend(alertErrors);
  setTimeout(function() {
    $("#product-flash-notice").remove();
  }, 3000);
}

function setSellerSearchMenuAndQueryName() {
  $('.seller-products-filters a').click(function(e) {
    e.preventDefault();
    let currentFilter = $(this).text().trim();
    let searchField = $('.seller-product-search-field');
    let filterType = $('#product-filter-type');
    $('.seller-products-filters a').removeClass('active');
    $(this).addClass('active')
    $('.current-search-filter').html(currentFilter + ' <i class="fa fa-angle-down ml-2" aria-hidden="true"></i>');
    if (currentFilter == 'Product Title') {
      searchField.attr('name', 'q[title_cont]');
      $('#csfn').val('title_cont');
      filterType.val('Product Title');
    } else if (currentFilter == 'Brand') {
      searchField.attr('name', 'q[brand_cont]');
      $('#csfn').val('brand_cont');
      filterType.val('Brand');
    } else if (currentFilter == 'SKU') {
      searchField.attr('name', 'q[sku_cont]');
      $('#csfn').val('sku_cont');
      filterType.val('SKU');
    } else if (currentFilter == 'YAN') {
      searchField.attr('name', 'q[yan_cont]');
      $('#csfn').val('yan_cont');
      filterType.val('YAN');
    } else if (currentFilter == 'EAN') {
      searchField.attr('name', 'q[ean_cont]');
      $('#csfn').val('ean_cont');
      filterType.val('EAN');
    } else {
      searchField.attr('name', 'q[title_or_brand_or_sku_or_yan_or_ean_cont]');
      $('#csfn').val('title_or_brand_or_sku_or_yan_or_ean_cont');
      filterType.val('Search All');
    }
  });
}

function setYavoloSearchMenuAndQueryName() {
  $('.seller-yavolos-filters a').click(function(e) {
    e.preventDefault();
    let currentFilter = $(this).text().trim();
    let searchField = $('.seller-yavolo-search-field');
    let filterType = $('#yavolo-filter-type');
    $('.seller-yavolos-filters a').removeClass('active');
    $(this).addClass('active')
    $('.current-search-filter-yavolo').html(currentFilter + ' <i class="fa fa-angle-down ml-2" aria-hidden="true"></i>');
    if (currentFilter == 'Product Title') {
      searchField.attr('name', 'q[products_title_cont]');
      $('#csfn').val('products_title_cont');
      filterType.val('Product Title');
    } else if (currentFilter == 'Brand') {
      searchField.attr('name', 'q[products_brand_cont]');
      $('#csfn').val('products_brand_cont');
      filterType.val('Brand');
    } else if (currentFilter == 'SKU') {
      searchField.attr('name', 'q[products_sku_cont]');
      $('#csfn').val('products_sku_cont');
      filterType.val('SKU');
    } else if (currentFilter == 'YAN') {
      searchField.attr('name', 'q[products_yan_cont]');
      $('#csfn').val('products_yan_cont');
      filterType.val('YAN');
    } else if (currentFilter == 'EAN') {
      searchField.attr('name', 'q[products_ean_cont]');
      $('#csfn').val('products_ean_cont');
      filterType.val('EAN');
    } else {
      searchField.attr('name', 'q[products_title_or_products_brand_or_products_sku_or_products_yan_or_products_ean_cont]');
      $('#csfn').val('products_title_or_products_brand_or_products_sku_or_products_yan_or_products_ean_cont');
      filterType.val('Search All');
    }
  });
}

$(document).ready(function() {
  $('body').on('click', '.preview_listing', function() {

    let all_images = $('.product-photos-grid > .p-1 > .grid-single-img > span').children('img').map(function() {
      return $(this).attr('src')
    }).get()

    $.ajax({
      url: "/" + $('#namespace').val() + "/preview_listing",
      data: {
        id: $("#product_id").val(),
        title: $("#product_title").val(),
        condition: $("#product_condition").val(),
        description: $(".ck-content").html(),
        price: $("#product_price").val().replace('£', ''),
        width: $("#product_width").val(),
        depth: $("#product_depth").val(),
        height: $("#product_height").val(),
        colour: $("#product_colour").val(),
        product_handle: $("#product_handle").val(),
        material: $("#product_material").val(),
        images: all_images
      },
      type: 'put',
      success: function(response) {
        window.open(window.location.protocol + "//" + window.location.host + "/product/" + response.product_handle + "?preview_listing=true", '_blank').focus();
      }
    });
  });
});

window.validateProductForm = function(custom_rules = {}, custom_messages = {}) {

  jQuery.validator.addMethod("descriptionPresent", function(value) {
    let content_length = product_description_editor.getData().trim().length;
    return content_length > 0;
  }, "Please add some description about your product.");

  let rules = {
    "product[title]": {
      required: true
    },
    "product[ean]": {
      required: true,
      maxlength: 13
    },
    "product[price]": {
      required: true,
      maxlength: 11,
    },
    "product[stock]": {
      required: true,
      maxlength: 4
    },
    "product[condition]": {
      required: true
    },
    "product[delivery_option_id]": {
      required: true
    }
  };

  let messages = {
    "product[title]": {
      required: "Title can\'t be blank"
    },
    "product[ean]": {
      required: "EAN can\'t be blank"
    },
    "product[price]": {
      required: "Price can\'t be blank",
      maxlength: "Please enter no more than 999,999"
    },
    "product[stock]": {
      required: "Stock can\'t be blank",
      maxlength: "Stock must be 1 to 9999"
    },
    "product[condition]": {
      required: "Condition can\'t be blank"
    },
    "product[delivery_option_id]": {
      required: "Please select a delivery option"
    }
  };

  $('form#product_form').validate({
    invalidHandler: function(event, validator) {
      if (!validator.numberOfInvalids())
        return;
      $('html, body').animate({
        scrollTop: $($(validator.errorList[0].element).parent()).offset().top - 100
      }, 2000);
    },
    ignore: "#product_width,#product_depth,#product_height,.ck-hidden, .ignoreme, .ck",
    rules: {
      ...rules,
      ...custom_rules
    },
    errorPlacement: function(error, element) {
      if (element.is(":radio")) {
        $('.d-option-id').show();
      } else {
        if (element.attr('name') == 'product[description]') {
          $(element).parents('.form-group').append(error);
        } else if (element.attr('name') == 'product[assigned_category_attributes][category_id]') {
          $(element).parents('.form-group').append(error)
        } else if ($('#namespace').val() == 'admin' && element.attr('name') == 'product[owner_id]') {
          $(element).parents('.form-group').append(error)
        } else {
          error.insertAfter(element);
        }
      }
    },
    highlight: function(element) {
      if (element.name == "product[assigned_category_attributes][category_id]") {
        $(element).parents('.form-group').find(".select2-selection.select2-selection--single").addClass('custom-border');
      } else if (element.name == "product[keywords]") {
        $(element).parents('.form-group').addClass('error-field')
      } else if (element.name == "product[owner_id]" && $('#namespace').val() == 'admin') {
        $(element).parents('.form-group').find(".select2-selection.select2-selection--single").addClass('custom-border');
      } else {
        $(element).parents("div.form-group").addClass('error-field');
      }
    },
    unhighlight: function(element) {
      if ($(element).attr('name') == "product[keywords]") {
        $(element).parents('.form-group').removeClass('error-field')
      } else if ($(element).attr('name') == "product[delivery_option_id]") {
        $('.d-option-id').hide();
      } else if ($(element).attr('name') == "product[assigned_category_attributes][category_id]") {
        $(element).parents('.form-group').find(".select2-selection.select2-selection--single").removeClass('custom-border');
        $(element).parents('.form-group').find('label.error').remove();
      } else if ($(element).attr('name') == "product[owner_id]" && $('#namespace').val() == 'admin') {
        $(element).parents('.form-group').find(".select2-selection.select2-selection--single").removeClass('custom-border');
        $(element).parents('.form-group').find('label.error').remove();
      } else {
        $(element).parents("div.form-group").removeClass('error-field');
      }
    },
    messages: {
      ...messages,
      ...custom_messages
    }
  });

  $('#product_keywords').change(function() {
    $(this).valid();
  })
  $('#product_keywords').rules('add', {
    required: true,
    messages: {
      required: "Keywords can\'t be blank"
    }
  });

  $('#product_category').change(function() {
    $(this).valid();
  })
  $('#product_category').rules('add', {
    required: true,
    messages: {
      required: "Category can\'t be blank"
    }
  });

  if ($('#namespace').val() == 'admin') {
    $('#search_seller_select').rules('add', {
      required: true,
      messages: {
        required: "Please select a seller."
      }
    });
    $('#search_seller_select').change(function() {
      $(this).valid();
    });
  }




  $('#product_description').change(function() {
    $(this).valid();
  })
  $('#product_description').rules('add', {
    descriptionPresent: true,
    messages: {
      descriptionPresent: "Please add some description about your product."
    }
  });

  $('#product_ean').change(function() {
    $(this).valid();
  })
  $('#product_ean').rules('add', {
    productEan: true,
    messages: {
      productEan: 'Please Enter a valid EAN.'
    }
  });

  $('#product_discount').change(function() {
    $(this).valid();
  })
  $('#product_discount').rules('add', {
    productDiscount: true,
    messages: {
      productDiscount: 'Discount value should be between 2.5 and 100'
    }
  });
}


function divAdjusterWidth() {
  if (window.location.pathname.split("/").pop() == 'new' || window.location.pathname.split("/").pop() == 'edit') {
    if ($('.grid-single-img').length == $('.remove').length) {
      $('.add-edit-product-photos').removeClass('col-lg-8').addClass('col-lg-12');
    }
  }
}

function eanErrorRemoveBackend() {
  $(".ean-product-field").on('input', function() {
    if ($(this).parent().find('.form-text')[0])
      $(this).parent().find('.form-text')[0].remove()
  })
}

function updateBulkActions(res, classNameOfAction, val) {
  res.update_ids.forEach(function(item) {
    $("#prod-id-" + item).find(classNameOfAction).text(val+"%");
    $("#prod-id-" + item).find(classNameOfAction).val(val);
  });
}


function stockUpdateOnListing() {
  $('body').on('input', '#pr-stock', function() {
    if ($(this).val().length > 4 || $(this).val().length == 0) {
      if ($(this).siblings('#quantity-error').length == 0) {
        $(this).parents("div.form-group").addClass('error-field');
        $(this).after('<label name="product-quantity" id= "quantity-error" class="text-left w-100 error text- absolute">Must be 1 to 9999</label>');
      }
    } else {
      $(this).parents("div.form-group").removeClass('error-field');
      $(this).siblings("#quantity-error").remove();
    }
  });
}

function priceUpdateOnListing() {
  $('body').on('input', '#pr-price', function() {
    let price = $(this).val().replace('£', '');
    if (price.length > 10 || price == 0.00) {
      if ($(this).siblings('#price-error').length == 0) {
        $(this).parents("div.form-group").addClass('error-field');
        $(this).after("<label name='product-price' id='price-error' class='text-left w-100 error text- absolute'>Must be 1 to 999999</label>");
      }
    } else {
      $(this).parents("div.form-group").removeClass('error-field');
      $(this).siblings("#price-error").remove();
    }
  });
}

function discountUpdateOnListing() {
  $('body').on('input', '#pr-discount', function() {
    let discount = $(this).val().replace("%", "")
    if (discount) {
      discount = parseFloat(discount)
    }
    if (discount < 2.5 || discount > 100) {
      if ($(this).siblings('#discount-error').length == 0) {
        $(this).parents("div.form-group").addClass('error-field');
        $(this).after('<label name="product-discount" id= "discount-error" class="text-left w-100 error text- absolute">Must 2.5 to 100</label>');
      }
    } else {
      $(this).parents("div.form-group").removeClass('error-field');
      $(this).siblings("#discount-error").remove();
    }
  });
}

function inputMaskCurrencyField() {
  $('#product_google_shopping_attributes_price').inputmask('currency', {
    prefix: '£',
    rightAlign: false
  });
}

function yavoloDiscountValidation(){
  if ($('#product_discount').val() >= 2.5 && $('#product_discount').val() <= 100) {
    if ($('#product_discount-error').text().length > 0) {
      $('#product_discount-error').text('');
    }
  } else {
    if ($('#product_discount-error').text().length == 0) {
      $('#product_discount-error').text('Discount value should be between 2.5 and 100');
    }
  }
}

function removeOrdersSearch() {
  $('body').on('click', '.rm-products-search', function(e) {
    e.preventDefault();
    $('.seller-product-search-field').val('');
    $('form#product_search').submit();
  });
}

function validateEAN() {
  $('body').on('change', '#product_ean', function() {
    let ean_val = $('#product_ean').val();
    if (ean_val.length == 13) {
      $.ajax({
        url: '/admin/products/verify_ean',
        type: 'get',
        data: {ean: ean_val},
        success: function(status){
          if (status) {
            $('#product_ean').parent().addClass('error-field');
            $('#product_ean').after("<small class='form-text product-ean-matched'>Ean has already been taken</small>");
          }
        }
      });
    }
  });
}

function validateEANBeforeSubmission() {
  $('body').on('click', '.product-form-submission', function(e) {
    e.preventDefault();
    let error_label = $('#product_ean').next();
    if ($("[class*=error-field]").length > 0) {
      $('html, body').animate({
        scrollTop: $("[class*=error-field]").first().offset().top - 100
      }, 2000);
    }
    else if ((error_label.length > 0) && error_label.hasClass('product-ean-matched')) {
      $('html, body').animate({
        scrollTop: $('#product_ean').offset().top - 120
      }, 2000);
    } else {
      $('form#product_form').submit();
    }
  });
}
