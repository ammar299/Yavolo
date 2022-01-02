$(document).ready(function () {

    uploadCsvDragDropShared();

    $(".upload-csv-shared-file-field").change(function (e) {
        let files = e.target.files;
        let fileValidator = validCsvFile(files);
        if (fileValidator.isValid) {
            $("#upload-csv-popup-shared .modal-body").find(".file-errors").remove();
            const importUrl = $(this).data('import-url')
            uploadCSVFileShared(files,importUrl);
        } else {
            document.getElementById("csv_import_sellers_file").value = "";
            $("#upload-csv-popup-shared .modal-body").find(".file-errors").remove();
            $("#upload-csv-popup-shared .modal-body").append(
                '<ul class="file-errors" style="color: red;">' +
                fileValidator.errors.map((e) => "<li>" + e + "</li>").join("") +
                "</ul>"
            );
        }
    });

    function uploadCSVFileShared(files,importUrl) {
        $("#csv_import_sellers_file").attr("disabled", true);
        let formData = new FormData();
        formData.append("file", files[0]);
        $.ajax({
            url: importUrl,
            type: "POST",
            data: formData,
            processData: false, // tell jQuery not to process the data
            contentType: false, // tell jQuery not to set contentType
            success: function (res) {
                $("#upload-csv-popup-shared").modal("hide");
                $("#upload-csv-success-popup-shared").modal("show");
                // $("#csv_import_sellers_file").attr("disabled", false);
            },
            error: function (xhr) {
               $(".upload-csv-shared-file-field").val("");
                $("#upload-csv-popup-shared .modal-body").find(".file-errors").remove();
                $("#upload-csv-popup-shared .modal-body").append(
                    '<ul class="file-errors" style="color: red;">' +
                    [xhr.responseJSON.errors].map((e) => "<li>" + e + "</li>").join("") +
                    "</ul>"
                );
                // hide any loading image
                // $("#csv_import_sellers_file").attr("disabled", false);
            },
        });
    }

    function validCsvFile(files) {
        let allowedExtensions = /(\.csv)$/i;
        let errors = [];
        if (!allowedExtensions.exec(files[0].name)) {
            errors.push("Invalid file type, allowed type is .csv");
        }
        let size = files[0].size / 1024 / 1024;

        if (size > 10) {
            errors.push("File size should be less than 10MB");
        }
        return { errors: errors, isValid: !(errors.length > 0) };
    }

    function uploadCsvDragDropShared() {
        if (document.getElementById("upload-csv-popup-shared"))
            bindDragAndDropEventsShared("upload-csv-popup-shared");
    }

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    function bindDragAndDropEventsShared(dropAreaId) {
        let dropArea = document.getElementById(dropAreaId);
        ["dragenter", "dragover", "dragleave", "drop"].forEach((eventName) => {
            dropArea.addEventListener(eventName, preventDefaults, false);
        });
        dropArea.addEventListener("drop", fileDropHandlerShared, false);
    }

    function fileDropHandlerShared(e) {
        let dt = e.dataTransfer;
        let files = dt.files;
        let fileValidator = validCsvFile(files);
        if (fileValidator.isValid) {
            $("#upload-csv-popup-shared .modal-body").find(".file-errors").remove();
            const importUrl = $(".upload-csv-shared-file-field").data('import-url')
            uploadCSVFileShared(files, importUrl);
        } else {
            $("#upload-csv-popup-shared .modal-body").find(".file-errors").remove();
            $("#upload-csv-popup-shared .modal-body").append(
                '<ul class="file-errors" style="color: red;">' +
                fileValidator.errors.map((e) => "<li>" + e + "</li>").join("") +
                "</ul>"
            );
        }
    }
})



