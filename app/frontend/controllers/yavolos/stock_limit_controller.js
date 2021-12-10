import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["stockLimit"]

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

    fetchLeastStock(){
        let url = this.data.get("url")
        if (!url) return;
        url = `${url}?product_ids=${this.summaryController.productIds}`
        this.getLeastStockFromBackend(url).then(data => data.json()).then(data => this.setStockLimit(data.stockValue))
    }

    getLeastStockFromBackend = async (url = '') => {
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        return response;
    }

    setStockLimit(value){
        if(value){
            this.stockLimitTarget.value = value;
        }
    }

    get summaryController() {
        return this.application.getControllerForElementAndIdentifier(this.element.closest(".yavolos--summary"), "yavolos--summary")
    }

}