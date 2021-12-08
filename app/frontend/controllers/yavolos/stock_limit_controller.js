import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["productsContainer", "stockLimitContainer"]

    connect() {
        this.toggleUI(this.summaryController.isAnyProductAddedToBundle())
    }

    toggleUI(isAnyProductAddedToBundle= false) {
        if(isAnyProductAddedToBundle) {
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

    toggleInputField(e){
        e.preventDefault();
        const input = ($(e.target).parents('.form-group').find("input"))[0];
        $(input).toggleClass("visible").toggleClass("invisible")
    }

    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(this.element.closest(".yavolos--summary"), "yavolos--summary")
    }

}