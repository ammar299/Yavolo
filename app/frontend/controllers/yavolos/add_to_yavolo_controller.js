import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = []

    connect() {

    }

    addToBundle(e) {
        e.preventDefault()
        const productId = this.data.get("productId")
        const url = this.data.get("url")
        if (!productId) return;
        this.fetchProductDetails(url).then(data => data.json()).then(data => this.renderItemInSummary(data))
    }

    fetchProductDetails = async (url = '') => {
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        return response;
    }

    renderItemInSummary(data) {
        if (!data) return;
        this.manualBundlesController.summaryController.appendProductItem(data)
    }

    get manualBundlesController() {
        return this.application.getControllerForElementAndIdentifier(this.element.closest(".yavolos--manual-bundles"), "yavolos--manual-bundles")
    }

}