import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["deleteBtn"]

    confirmedDelete(){
        this.summaryController.removeProductsConfirmed()
    }


    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(document.querySelector(".yavolos--summary"), "yavolos--summary")
    }

}