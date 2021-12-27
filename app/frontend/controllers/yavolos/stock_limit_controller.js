import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["stockLimit","maxStockLimit","errorText"]

    connect() {
        this.toggleUI(this.summaryController.isAnyProductAddedToBundle())
        this.isMaxStockLimitFieldValid = this.maxStockLimitTarget.value.length > 0
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

    validateMaxStockLimitField(e) {
        let value = $(e.target).val();
        let minValue = $(e.target).attr('min');
        let maxValue = $(e.target).attr('max');
        if (!value) {
            this.showMaxStockLimitErrorMessage()
            return
        }
        value = parseInt(value);
        minValue = parseInt(minValue);
        maxValue = parseInt(maxValue);
        if (value < minValue || value > maxValue) {
            this.showMaxStockLimitErrorMessage()
        } else {
            this.errorTextTarget.classList.add("d-none")
            this.isMaxStockLimitFieldValid = true
        }
    }

    showMaxStockLimitErrorMessage(){
        this.errorTextTarget.classList.remove("d-none")
        this.isMaxStockLimitFieldValid = false
    }

    toggleMaxStockLimitInputFieldAndShowErrorMessage(){
        $(this.maxStockLimitTarget).addClass("visible")
        this.showMaxStockLimitErrorMessage()
        $('html, body').animate({
            scrollTop: $(this.maxStockLimitTarget).offset().top - 100
        }, 2000);
    }

    toggleInputField(e){
        e.preventDefault();
        const input = ($(e.target).parents('.form-group').find("input"))[0];
        $(input).toggleClass("visible").toggleClass("invisible")
        if($(input).hasClass("invisible") && $(input).siblings(".input-error-text").length){
            $(input).siblings(".input-error-text").addClass("d-none")
        }
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