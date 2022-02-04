// Source code copied from this link
// https://derk-jan.com/2020/10/rails-ujs-custom-confirm/
$(document).ready(function () {
    let __SkipConfirmation = false;

    Rails.confirm = function (message, element) {
        if (__SkipConfirmation) {
            return true;
        }

        function onConfirm() {
            __SkipConfirmation = true
            element.click()
            __SkipConfirmation = false
        }

        if(element.getAttribute('data-bulk')){
            handleBulkActionForDataConfirm(element,onConfirm)
        } else {
            showConfirmDialog(element, onConfirm)
        }

        return false;
    };

    function handleBulkActionForDataConfirm(element,onConfirm) {
        let selected_items = []
        const bulkCheckboxSelector = element.getAttribute('data-bulk-checkboxes-selector')
        $(`${bulkCheckboxSelector} input[type=checkbox]:checked`).each(function () {
            selected_items.push($(this).val())
        });
        if (selected_items.length < 1) {
            window.displayNoticeMessage("Please select some items first");
        } else {
            const href_val = `${element.getAttribute("href")}?ids=${selected_items.join(",")}`;
            $(element).attr('href', href_val)
            showConfirmDialog(element, onConfirm)
        }
    }

    function showConfirmDialog(link, onConfirm) {
        const message = link.getAttribute('data-confirm')
        const html = `
         <div class="modal fade rails-confirm-delete-modal" tabindex="-1" role="dialog" aria-labelledby="deliveryOptionFormLabel" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title"></h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">×</span>
                </button>
              </div>
              <div class="modal-body delete-modal-body">
                <p class="pb-4 confirmation-text">${message || "Are you sure you want to perform this action?"}</p>
                <div class="carrier-btn text-right">
                  <div class="btn btn-sm btn-radius px-4 btn-primary mt-2" data-dismiss="modal">
                    No
                  </div>
                  <a href="#" data-dismiss="modal" class="btn btn-sm btn-radius px-4 btn-primary mt-2 ml-2 confirm">Yes</a>
                </div>
              </div>
            </div>
          </div>
        </div>
         `
        $(html).modal('show')

        $(document).on('click', '.rails-confirm-delete-modal .confirm', function () {
            onConfirm()
        });
    }
});

