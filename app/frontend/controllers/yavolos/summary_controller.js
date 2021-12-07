import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["productsContainer", "productCheckbox"]

    connect() {
        this.productIds = []
    }

    appendProductItem(data) {
        const {product_id, raw_html} = data;
        if (this.isProductAlreadyAdded(product_id)) {
            window.displayNoticeMessage("Product already added to bundle")
        } else {
            this.addProductItemToDOM(raw_html)
            this.saveProductId((product_id))
        }
        this.stockLimitController.toggleUI(this.isAnyProductAddedToBundle())
        this.totalPricesController.toggleUI(this.isAnyProductAddedToBundle())
    }

    addProductItemToDOM(html) {
        this.productsContainerTarget.insertAdjacentHTML('beforeend', html)
    }

    removeSelectedProductsFromDOM(e) {
        e.preventDefault();
        const checkboxes = this.productCheckboxTargets;
        const isAnyCheckboxChecked = checkboxes.some((c) => c.checked)
        if (!isAnyCheckboxChecked) {
            window.displayNoticeMessage("Please select some product to remove")
            return;
        }
        for (let checkbox of checkboxes) {
            this.removeSingleProduct(checkbox)
        }
        this.stockLimitController.toggleUI(this.isAnyProductAddedToBundle())
        this.totalPricesController.toggleUI(this.isAnyProductAddedToBundle())
        this.changeProductsCounterHeading()
    }

    removeSingleProduct(checkbox){
        if (!checkbox.checked) return;
        const productId = checkbox.dataset.productId
        this.removeProductId(productId)
        checkbox.closest(".yavolos--product-item").remove()
    }

    changeProductsCounterHeading() {
        const controllerThis= this
        // Added setTimout because it takes some time for product item controller to disconned
        setTimeout(function () {
                let counter = 1
                for (let controller of controllerThis.getAllPricesControllers()) {
                    controller.setCountTarget(counter)
                    counter++;
                }
            }
            , 300);
    }

    isProductAlreadyAdded(id) {
        return this.productIds.includes(id)
    }

    saveProductId(id) {
        this.productIds.push(id)
    }

    removeProductId(id) {
        this.productIds = this.productIds.filter(p => p != id)
    }

    isAnyProductAddedToBundle() {
        return this.productIds.length > 0
    }

    get manualBundlesController() {
        return this.application.getControllerForElementAndIdentifier(this.element.closest(".yavolos--manual-bundles"), "yavolos--manual-bundles")
    }

    get stockLimitController() {
        return this.manualBundlesController.stockLimitController
    }

    get totalPricesController() {
        return this.application.getControllerForElementAndIdentifier(this.element.querySelector(".yavolos--total-prices"), "yavolos--total-prices")
    }

    getAllPricesControllers() {
        return this.application.controllers.filter(controller => {
            return controller.context.identifier === "yavolos--product-item";
        });
    }


}