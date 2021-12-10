import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["counter", "errorText", "regularPriceInput", "discountPriceInput"]

    connect() {
        this.addCount()
        this.inputMaskCurrencyFields()
        this.isDiscountValid = true
    }

    addCount() {
        this.setCountTarget($(".yavolos--product-item").length)
    }

    setCountTarget(value) {
        this.counterTarget.innerHTML = value;
    }

    inputMaskCurrencyFields() {
        $(this.element).find(".yo-price-inpt").inputmask('currency', {
            prefix: '£',
            rightAlign: false
        });
    }

    validateDiscountPrice(e) {
        let value = $(e.target).val();
        let minValue = $(e.target).attr('min');
        let maxValue = $(e.target).attr('max');
        if (!value) {
            this.errorTextTarget.classList.remove("d-none")
            this.isDiscountValid = false
            return
        }
        value = parseFloat(value.replace("£", ""));
        minValue = parseFloat(minValue);
        maxValue = parseFloat(maxValue);
        if (value < minValue || value > maxValue) {
            this.errorTextTarget.classList.remove("d-none")
            this.isDiscountValid = false
        } else {
            this.errorTextTarget.classList.add("d-none")
            this.isDiscountValid = true
            this.summaryController.totalPricesController.setPrices()
        }
    }

    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(this.element.closest(".yavolos--summary"), "yavolos--summary")
    }

}