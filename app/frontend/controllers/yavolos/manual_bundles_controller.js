import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = []

    connect() {
    }

    onBack(e){
        e.preventDefault();
        this.backButtonModalController.showModal();
    }

    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(this.element.querySelector(".yavolos--summary"), "yavolos--summary")
    }

    get stockLimitController(){
        return this.application.getControllerForElementAndIdentifier(this.element.querySelector(".yavolos--stock-limit"), "yavolos--stock-limit")
    }

    get backButtonModalController(){
        return this.application.getControllerForElementAndIdentifier(document.querySelector(".yavolos--back-button-modal"), "yavolos--back-button-modal")
    }

}