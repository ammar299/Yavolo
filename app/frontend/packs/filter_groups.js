$(document).ready(function(){
	$('#delete-filter-groups').click(() => deletefilterGroups());
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
});

function deletefilterGroups() {
	$('#select-filter-groups').submit();
}