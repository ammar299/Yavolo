$(document).ready(function () {
    $('#categories-tree ul:not(:first-child)').addClass('ml-4')
    $('#categories-tree li').children('ul').toggle();

    createCategoryLinkingFilter();
    selectImagesfromS3();
	   selectImagesFromLocalStorage();
     tempRemoveBtn();
    categoryInformResult();
    $('body').on('change', '.categories-checkbox-container .category-input', function () {
        createNewCategory($(this)[0]);
        fetchCategoryDetails($(this)[0])
    });
    const selectedIdCategory = $(".categories-tree-body .category-input[data-selected='true']")
    if(selectedIdCategory.length){
        selectedIdCategory.prop('checked', true).trigger('change')
        selectedIdCategory.parents('ul').addClass('active')
        selectedIdCategory.attr('data-selected', false)
    } else{
        $(".categories-tree-body ul:first-of-type li:first .category-input:first").prop('checked', true).trigger('change')
    }

    $('body').on('change', '.filter-groups-select-all-container #filter-group-select-all', function () {
        if ($('#filter-group-select-all').is(':checked')) {
            $('.filter-groups-checkbox-container input:checkbox').prop('checked', true)
        } else {
            $('.filter-groups-checkbox-container input:checkbox').prop('checked', false)
        }
    });

    $('body').on('click', '#category-description-form .remove_category_image', function (e) {
        e.preventDefault();
        const url = $(this).attr('href')
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", url).attr('data-remote', true)
        $('#delete-confirmation-modal').modal('show');
    });

    $(".delete-category-action-btn").click(function (e) {
        e.preventDefault();
        const id = $(".categories-checkbox-container .category-input:checked").attr('name')
        if (!id) return;
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", `/admin/categories/${id}`).attr('data-remote', false)
        $('#delete-confirmation-modal').modal('show');
    })

    $('body').on('click', '.remove-category-products-btn', function (e) {
        e.preventDefault();
        let selected_options = []

        $('.filter-groups-checkbox-container input[type=checkbox]:checked').each(function () {
            selected_options.push($(this).val())
        });

        if (!selected_options.length > 0) return;
        const per_page = $(".category-products-per-page").val()
        const current_page = $("#category_paginator .page-item.active .page-link").text()
        const query_term = $(".category-products-search-term").val()
        const newUrl = `${$(this).attr('href')}?product_ids=${selected_options}&per_page=${per_page}&page=${current_page}&q=${query_term}`
        $("#delete-confirmation-modal .confirm-delete-btn").attr("href", newUrl).attr('data-remote', true)
        $('#delete-confirmation-modal').modal('show');
    });

    $('body').on('click', '#category_paginator .page-link', function (e) {
        e.preventDefault();
        const per_page = $(".category-products-per-page").val()
        const query_term = $(".category-products-search-term").val()
        if (!$(this).attr('href')) return;
        const newUrl = `${$(this).attr('href')}&per_page=${per_page}&q=${query_term}`
        $(this).attr('href', newUrl)
        e.returnValue = true;
    });

    $('body').on('change', '.category-products-per-page', function (e) {
        const current_page = $("#category_paginator .page-item.active .page-link").text()
        $(".category-products-form .page-number").val(current_page)
        $(".submit-category-products-form-btn").click()
    });


});

function selectImagesfromS3() {
	$('body').on('click', '.selected-image', function() {
		addCustomImg();
    if(!$('.temp-preview-button').hasClass('d-none')){
      $('.remove_category_image').hide();
    }
    $('#category_picture_attributes_name').val("");
		$("#picture-id-saved").val($(this).data('picid'));
		$('.product-content-img').data('currentsrc',$(".product-content-img").attr('src'))
    $(".product-content-img").attr('src' , $(this).attr('src'));
    $("#upload-images-popup").modal('hide');
	});
}

function selectImagesFromLocalStorage() {
	$('body').on('change', '#category_picture_attributes_name', function() {
		addCustomImg();
    if(!$('.temp-preview-button').hasClass('d-none')){
      $('.remove_category_image').hide();
    }
    $('.product-content-img').data('currentsrc', $(".product-content-img").attr('src'));
		$('.product-content-img').attr('src', URL.createObjectURL(event.target.files[0]));
	});
}

function addCustomImg() {
	if ($('.product-content-img').length == 0) {
		$('#category-image-preview').html("<img src='' alt='' class='product-content-img'></img>");
	}
  // if ($('.product-content-img').length == 1) {
  //   $("#remove-picture").trigger("click")
  //   event.preventDefault();
  // }

	$('.product-content-img').removeClass('d-none');
  $('.temp-preview-button').removeClass('d-none');
}

function tempRemoveBtn(){
  $('body').on('click', '.temp-preview-button', function(){
    // $('.product-content-img').remove();
    $('.product-content-img').attr('src',$(".product-content-img").data('currentsrc') )
    $('#remove-picture').show();
    if($('.product-content-img').attr('src')=='')
      $('.product-content-img').addClass('d-none');

    $('.temp-preview-button').addClass('d-none');
    $('#category_picture_attributes_name').val("");
    $('#picture-id-saved').val("");
  });
}

function createCategoryLinkingFilter() {
	$('body').on('change', '#category_linking_filters', function () {
		var category_val = $('#category_id').val();
		var filter_in_category_val = $('#category_linking_filters').val();
		url = '/admin/categories/manage_category_linking_filter'
    $.ajax({
      url: url,
      type: 'get',
    	data: {category_id: category_val, filter_in_category_id: filter_in_category_val}
    });
	});
}

function fetchCategoryDetails(element) {
    let selected_category = $(element).attr("name")
    $.ajax({
        method: 'GET',
        url: `/admin/categories/${selected_category}/category_details`,
        success: function (data) {
            if (!data) return
            $(".category-details-wrapper").html(data)
            validateCategoryForm();
        }
    })
}

function createNewCategory(element) {
    $(element).closest('li').find('ul').removeClass('active');
    if (element.checked) {
        $(element).closest('li').children('ul').addClass('active');
        $('.category-input').not(element).prop('checked', false);
        let is_baby_category = $(element).attr("data-baby-category") === "true"
        if (is_baby_category) {
            $('.sub-category-link').addClass('disabled');
        } else {
            $('.sub-category-link').removeClass('disabled');
        }

    } else {
        $(element).closest('li').children('ul').removeClass('active');
        $('.sub-category-link').addClass('disabled');
    }
}

function categoryInformResult(){
  $('body').on('keyup', '.category-products-search-term', function(){
    $('.submit-category-products-form-btn').trigger('click');
  });
}

window.validateCategoryForm = function() {
  $('form#category-description-form').validate({
    invalidHandler: function(event,validator){
      if (!validator.numberOfInvalids())
            return;

      $('html, body').animate({
          scrollTop: $('body').offset().top
      }, 1000);
    },
    ignore: ".ck",
    rules: {
      "category[category_name]": {
        required: true
      }
    },
    highlight: function(element) {
      $(element).parents("div.form-group").addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).parents("div.form-group").removeClass('error-field');
    },
    messages: {
      "category[category_name]": {
          required: "Category Name can't be blank."
      }
    }
  });
}
