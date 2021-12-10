import 'select2'
import 'select2/dist/css/select2.css'

$(document).ready(function () {
    initializeCKEditorOnYavoloManualFormFields();
    bindAndLoadCategoriesSelect2ForYavoloManualForm()
})

function initializeCKEditorOnYavoloManualFormFields(){
    if(!$('.ckeditor-field').length) return;
    $('.ckeditor-field').each(function (index,element) {
        ClassicEditor.create( element,{toolbar: [ 'bold', 'italic', '|' ,'bulletedList', 'numberedList' ]} ).catch( error => {
            console.error( error );
        } );
    })
}

function bindAndLoadCategoriesSelect2ForYavoloManualForm(){
    $('#yavolo_bundle_product_category').select2({
        theme: 'bootstrap4',
        ajax: {
            url: "/admin" +"/categories/search_all_categories",
            type: 'GET',
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    q: params.term,
                    page: params.page || 1
                };
            },
            processResults: function (data, params) {
                params.page = params.page || 1;
                return {
                    results: $.map(data.categories,function(e){ return {id: e.id, text: e.category_name}}),
                    pagination: {
                        more: (params.page * 10) < data.total_count
                    }
                };
            },
            cache: true
        },
        placeholder: 'Search category'
    });
}