import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["counter"]

    connect() {
        this.addCount()
        this.inputMaskCurrencyFields()
    }

    addCount(){
        this.setCountTarget($(".yavolos--product-item").length)
    }

    setCountTarget(value){
        this.counterTarget.innerHTML = value;
    }

    inputMaskCurrencyFields(){
        $(this.element).find(".yo-price-inpt").inputmask('currency', {
            prefix: '£',
            rightAlign: false
        });
    }

}