import 'select2'
import 'select2/dist/css/select2.css'

$(document).ready(function () {
    initializeCKEditorOnYavoloManualFormFields();
    bindAndLoadCategoriesSelect2ForYavoloManualForm()
    validateYavoloBundleForm();
    setExportData();
    setImportYavolos();
		inputMaskCurrencyField();

    if($('[name="products[][keywords][]"]').length) {
        $('[name="products[][keywords][]"]').on('itemAddedOnInit', function(event) {
            $(event.target).parents(".form-group").find(".bootstrap-tagsinput input").addClass('ignoreme')
        });
    }

    $(".yavolo-main-image-input-wrapper .yavolo-main-image-input").change(function () {
        previewFileForYavoloMainImage($(this))
    })

    $(".multiple-update-yavolos input").click(function () {
			if (!$(this).is(":checked")) {
				$("#check-all-checkboxes").prop("checked", false);
			}
    });

})

function setImportYavolos() {
    $(document).on("click", ".import-yavolos", function (e) {
        e.preventDefault()
        $("#upload-csv-popup-shared").modal('show')
    });
}

function previewFileForYavoloMainImage(input){
    const file = $(input).get(0).files[0];

    if(file){
        var reader = new FileReader();

        reader.onload = function(){
            const template = `
            <div class="row bundle-block-pad align-items-center one-to-three">
              <div class="col-12">
                <div class="yo-white-card">
                  <img src="${reader.result}">
                </div>
              </div>
            </div>
            `
            $(".yavolo-main-image-container").html(template);
        }

        reader.readAsDataURL(file);
    }
}

function setExportData(){
    $(document).on("click", ".export-yavolos", function (e) {
        e.preventDefault()
        var selected_yavolos = [];
        $(".multiple-update-yavolos input[type=checkbox]:checked").each(function () { //get selected yavolos
            selected_yavolos.push($(this).val());
        });
        if (selected_yavolos.length < 1) {
            exportAllYavolos(selected_yavolos) //export all yavolos
        } 
        else {
            $("#yavolos-trigger").attr("href","/admin/yavolos/manual_bundles/export_yavolos.csv?format=csv&yavolos=" + selected_yavolos) //export selected yavolos.
        }
        if (selected_yavolos.length !== 0){
            exportYavolosNotification(selected_yavolos)
            $("#yavolos-trigger")[0].click()
        }
        else{
            displayNoticeMessage("Nothing to export.")
        }
    });
}

function exportYavolosNotification(selected_yavolos){
    let msg = selected_yavolos.length <= 50 ? 'Yavolos Csv is being downloaded.' : 'Yavolos Csv will be sent to your email.'
    displayNoticeMessage(msg)
}

function exportAllYavolos(selected_yavolos){

    $(".multiple-update-yavolos input[type=checkbox]").each(function () { //get all yavolos
        selected_yavolos.push(parseInt($(this).val()));
    });
    
    $("#yavolos-trigger").attr("href","/admin/yavolos/manual_bundles/export_yavolos.csv?format=csv&yavolos=" + selected_yavolos)
}
function initializeCKEditorOnYavoloManualFormFields(){
    if(!$('.ckeditor-field').length) return;
    $('.ckeditor-field').each(function (index,element) {
        ClassicEditor.create( element,{toolbar: [ 'bold', 'italic', '|' ,'bulletedList', 'numberedList' ]} ).then(editor=>{
            if($(element).attr('id') == "yavolo_bundle_description"){
                editor.model.document.on( 'change:data', () => {
                    $('#yavolo_bundle_description').val(editor.getData().trim());
                    $('#yavolo_bundle_description').trigger('change');
                });
            }

        }).catch( error => {
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

const validateYavoloBundleForm = function(custom_rules={}, custom_messages={}) {
    jQuery.validator.addMethod("yavoloDescriptionPresent", function(value, element) {
        let content_length = value.trim().length;
        return content_length > 0;
    }, "Please add some description about your product.");

    let rules = {
        "yavolo_bundle[title]": {
            required: true
        }
    };

    let messages = {
        "yavolo_bundle[title]": {
            required: "Title can\'t be blank"
        }
    };

    $('form#yavolo_bundle_form').validate({
        invalidHandler: function(event,validator){
            if (!validator.numberOfInvalids())
                return;
            $('html, body').animate({
                scrollTop: $($(validator.errorList[0].element).parent()).offset().top - 100
            }, 2000);
        },
        ignore: "#product_width,#product_depth,#product_height,.ck-hidden, .ignoreme, .ck",
        rules: {...rules, ...custom_rules},
        errorPlacement: function(error, element){
            if (element.is(":radio")){
                $('.d-option-id').show();
            }else{
                if(["yavolo_bundle[category_id]","yavolo_bundle[description]"].includes(element.attr('name'))) {
                    $(element).parents('.form-group').append(error);
                } else{
                    error.insertAfter( element );
                }
            }
        },
        highlight: function(element) {
             if(element.name=="products[][keywords][]"){
                $(element).parents('.form-group').addClass('error-field')
            } else{
                $(element).parents("div.form-group").addClass('error-field');
            }
        },
        unhighlight: function(element) {
            if($(element).attr('name')=="products[][keywords][]"){

                $(element).parents('.form-group').removeClass('error-field')
            } else{
                $(element).parents("div.form-group").removeClass('error-field');
            }
        },
        messages: {...messages, ...custom_messages}
    });

    $('.yavolo-bundle-product-keywords-input').change(function(){
        $(this).valid();
    })

    $('[name="products[][keywords][]"]').each(function () {
        $(this).rules('add', {
            required: true,
            messages: {
                required: "Keywords can\'t be blank"
            }
        });
    })

    $('#yavolo_bundle_product_category').change(function(){
        $(this).valid();
    })
    $('#yavolo_bundle_product_category').rules('add', {
        required: true,
        messages: {
            required: "Category can\'t be blank"
        }
    });


    $('#yavolo_bundle_description').change(function(){
        $(this).valid();
    })
    $('#yavolo_bundle_description').rules('add', {
        yavoloDescriptionPresent: true,
        messages: {
            yavoloDescriptionPresent: "Please add some description about your product."
        }
    });

    // $('#product_ean').change(function() {
    //     $(this).valid();
    // })
    // $('#product_ean').rules('add', {
    //     productEan: true,
    //     messages: {
    //         productEan: 'Please Enter a valid EAN without decimal.'
    //     }
    // });
}

function inputMaskCurrencyField() {
  $('#yavolo_bundle_google_shopping_attributes_price').inputmask('currency', {
    prefix: '£',
    rightAlign: false
  });
}
