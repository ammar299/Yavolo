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

	  if (selected_options.length == 1) {
	    url = '/admin/filter_groups/assign_category?id=' + selected_options
	    $.ajax({
	      url: url,
	      type: 'GET'
	    });
	  }
	});
}