import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    // static targets = ["productsContainer", "stockLimitContainer"]

    connect() {

    }

    showModal(){
        $(this.element).modal('show')
        console.log("caleed")
    }

}