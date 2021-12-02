$(document).ready(function(){
	$('#assign-filter-group-category').attr('title', 'Please select just one filter group');
	assignFilterGroupCategory();
	$('body').on('change', '.filter-group-radio', function(){
		var filterType = $(this).parent().text().trim();
		var $globalCheck = $('#global-check');
		 $('#global-check').css({'display': 'block'});
		if(filterType == 'Local'){
			$globalCheck.css({'display': 'block'});
		}
		else {
			$globalCheck.css({'display': 'none'});
		}
	});

  $('body').on('change', 'input[type=checkbox]', function(){
    if($('input[type=checkbox]:checked').length == 0){
      $('#assign-filter-group-category').addClass("disabled");
    }else{
      $('#assign-filter-group-category').removeClass("disabled");
    }
  });

	// filter group form errors validation
	$('body').on('submit','form#filter_group_new_form',function(e){
    if(!validFilterGroupForm()){
      e.preventDefault();
      // $([document.documentElement, document.body]).animate({
      //   scrollTop: $("#filter_group_new_form").offset().top
      // }, 2000);
      // return;
    }
  });

	selectedFilterGroups();
});

function selectedFilterGroups() {
	$('.filter-groups-select-all-container #filter-group-select-all').change(function() {
		if ($('#filter-group-select-all').is(':checked')) {
			$('.filter-groups-checkbox-container input:checkbox').prop('checked', true)
		} else {
			$('.filter-groups-checkbox-container input:checkbox').prop('checked', false)
		}
	});
}

function assignFilterGroupCategory(){
	$('body').on('click', '#assign-filter-group-category', function(){
	  selected_options = []
	  $('.filter-groups-checkbox-container input[type=checkbox]:checked').each(function() {
	    selected_options.push($(this).val())
	  });

	  if (selected_options.length > 0) {
	    const url = '/admin/filter_groups/assign_category?id=' + selected_options
	    $.ajax({
	      url: url,
	      type: 'GET'
	    });
	  }
	});
}

function validFilterGroupForm(){
  let has_errors = []

  $("#filter_group_name").parents('.form-group').find('small').remove();
  if($("#filter_group_name").val().length > 0){
    $("#filter_group_name").parents('.form-group').removeClass('error-field')
    $("#filter_group_name").parents('.form-group').find('small').remove();
  }else{
    has_errors.push(true)
    $("#filter_group_name").parents('.form-group').addClass('error-field')
    $("#filter_group_name").parents('.form-group').append('<small class="form-text">Name can\'t be blank</small>')
  }
  return !has_errors.includes(true)
}

	// validations
window.FilterGroupFormValidation = function(){	
	$('form#filter_group_new_form').validate({
		ignore: "",
	  rules: {
      "filter_group[name]": {
        required: true,
				maxlength: 40
      },
      "filter_group[filter_group_type]": {
      	required: true
      },
			"filter_group[filter_in_categories_attributes][0][filter_name]": {
				required: true,
				maxlength: 25
			},
			"filter_group[filter_in_categories_attributes][0][sort_order]": {
				required: true,
				max: 2147483646
			}
    },
    errorPlacement: function (error, element) {
	    error.insertAfter(element);
	  },
    highlight: function(element) {
      $(element).closest('div').addClass('error-field');
    },
    unhighlight: function(element) {
      $(element).closest('div').removeClass('error-field');
    },
	  messages: {
      "filter_group[name]": {
        required: "Filter group name required",
				maxlength: "Name is too long"
       },
			 "filter_group[filter_in_categories_attributes][0][filter_name]": {
				maxlength: "Name is too long"
			},
			"filter_group[filter_in_categories_attributes][0][sort_order]": {
				max: "Value should be less than 2147483646"
			}
     }
	});
}

$(document).on('cocoon:after-insert', "#filter_in_categories",function(e, insertedItem, originalEvent) {
	$(insertedItem).find(".filter-name").rules("add",{
		maxlength: 30,
		messages:{
			maxlength: "Name is too long"
		}
	}),
	$(insertedItem).find(".filter-sort-order").rules("add",{
		max: 2147483646,
		messages:{
			max: "Value should be less than 2147483646"
		}
	})
})

