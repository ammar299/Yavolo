import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["form"]

    connect() {
    }

    onBack(e) {
        e.preventDefault();
        this.backButtonModalController.showModal();
    }

    continueToFormPage(e) {
        e.preventDefault();
        let productItems = this.areAllProductItemsValid()
        if(!productItems.valid){
            window.displayNoticeMessage(productItems.message)
            return
        }
        let stockLimit = this.isStockLimitValid()
        if(!stockLimit.valid){
            window.displayNoticeMessage(stockLimit.message)
            return
        }
        $(this.formTarget).submit();
    }



    areAllProductItemsValid() {
        let obj = {}
        const pricesControllers = this.summaryController.getAllPricesControllers()
        if (pricesControllers.length < 2) {
            obj['valid'] = false;
            obj['message'] = "Please add some products to bundle first"
        } else {
            obj['valid'] = pricesControllers.every(pc => pc.isDiscountValid === true)
            obj['message'] = "Please add correct value for product yavolo discount"
        }
        return obj;
    }

    isStockLimitValid() {
        let obj = {}
        const isMaxStockLimitFieldValid = this.stockLimitController.isMaxStockLimitFieldValid
        obj['valid'] = isMaxStockLimitFieldValid
        obj['message'] = "Please add correct value for max stock limit"
        return obj;
    }

    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(this.element.querySelector(".yavolos--summary"), "yavolos--summary")
    }

    get stockLimitController() {
        return this.application.getControllerForElementAndIdentifier(this.element.querySelector(".yavolos--stock-limit"), "yavolos--stock-limit")
    }

    get backButtonModalController() {
        return this.application.getControllerForElementAndIdentifier(document.querySelector(".yavolos--back-button-modal"), "yavolos--back-button-modal")
    }

}