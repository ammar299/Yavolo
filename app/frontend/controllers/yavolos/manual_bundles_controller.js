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
        const {valid,message} = this.areAllProductItemsValid()
        if(!valid){
            window.displayNoticeMessage(message)
            return
        }
        $(this.formTarget).submit();
    }



    areAllProductItemsValid() {
        let obj = {}
        const pricesControllers = this.summaryController.getAllPricesControllers()
        if (pricesControllers.length === 0) {
            obj['valid'] = false;
            obj['message'] = "Please add some products to bundle first"
        } else {
            obj['valid'] = pricesControllers.every(pc => pc.isDiscountValid === true)
            obj['message'] = "Please add correct value for product yavolo discount"
        }
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