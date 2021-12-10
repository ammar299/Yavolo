import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["total", "yavoloTotal", "adjustTotal"]

    connect() {
        this.toggleUI(this.summaryController.isAnyProductAddedToBundle())
        this.inputMaskCurrencyFields()
    }

    toggleUI(isAnyProductAddedToBundle = false) {
        if (isAnyProductAddedToBundle) {
            this.showElement()
        } else {
            this.hideELement()
        }
    }

    hideELement() {
        $(this.element).hide()
    }

    showElement() {
        $(this.element).show()
    }

    inputMaskCurrencyFields() {
        $(this.element).find(".yavolos--total-prices-input").inputmask('currency', {
            prefix: '£',
            rightAlign: false
        });
    }

    setPrices() {
        const controllerThis = this;
        setTimeout(function () {
            const pricesControllers = controllerThis.summaryController.getAllPricesControllers();
            const {regularTotal, yavoloTotal, adjustTotal} = controllerThis.calculateTotalPrices(pricesControllers);
            controllerThis.setRegularTotal(regularTotal)
            controllerThis.setYavoloTotal(yavoloTotal)
            controllerThis.setAdjustTotal(adjustTotal)
        }, 400)

    }

    calculateTotalPrices(pricesControllers) {
        let regularTotal = 0, yavoloTotal = 0, adjustTotal = 0;
        for (let priceController of pricesControllers) {
            let rtotal = priceController.regularPriceInputTarget.value.replace("£", "")
            let atotal = priceController.discountPriceInputTarget.value.replace("£", "")
            let ytotal = priceController.discountPriceInputTarget.dataset.discountPriceOriginal
            rtotal = rtotal ? parseFloat(rtotal) : 0.00;
            atotal = atotal ? parseFloat(atotal) : 0.00;
            ytotal = ytotal ? parseFloat(ytotal) : 0.00;
            regularTotal += rtotal;
            yavoloTotal += ytotal;
            adjustTotal += atotal
        }
        return {regularTotal, yavoloTotal, adjustTotal}
    }

    setRegularTotal(value) {
        this.totalTarget.value = value.toFixed(2)
    }

    setYavoloTotal(value) {
        this.yavoloTotalTarget.value = value.toFixed(2)
    }

    setAdjustTotal(value) {
        this.adjustTotalTarget.value = value.toFixed(2)
    }

    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(this.element.closest(".yavolos--summary"), "yavolos--summary")
    }

}