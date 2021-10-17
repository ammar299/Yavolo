$(document).ready(function(){
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
      $('#delete-filter-groups').addClass("disabled");
    }else{
      $('#delete-filter-groups').removeClass("disabled");
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
