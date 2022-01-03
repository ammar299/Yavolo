import {ApplicationController} from "../application_controller.js"

export default class extends ApplicationController {
    static targets = ["productsContainer", "productCheckbox"]

    connect() {
        this.productIds = []
    }

    appendProductItem(data) {
        const {product_id, raw_html} = data;
        if (this.isProductAlreadyAdded(product_id)) {
            window.displayNoticeMessage("Product already exists in bundle")
        } else {
            window.displayNoticeMessage("Product added to bundle")
            this.addProductItemToDOM(raw_html)
            this.saveProductId((product_id))
        }
        this.notifyDependentControllers()
    }

    addProductItemToDOM(html) {
        this.productsContainerTarget.insertAdjacentHTML('beforeend', html)
    }

    notifyDependentControllers() {
        this.stockLimitController.toggleUI(this.isAnyProductAddedToBundle())
        this.stockLimitController.fetchLeastStock()
        this.totalPricesController.toggleUI(this.isAnyProductAddedToBundle())
        this.totalPricesController.setPrices()
    }

    removeSelectedProductsFromDOM(e) {
        e.preventDefault();
        const checkboxes = this.productCheckboxTargets;
        const isAnyCheckboxChecked = checkboxes.some((c) => c.checked)
        if (!isAnyCheckboxChecked) {
            window.displayNoticeMessage("Please select some product to remove")
            return;
        }
        $(".yavolos--delete-confirmation-modal").modal('show')

    }

    removeProductsConfirmed() {
        const checkboxes = this.productCheckboxTargets;
        for (let checkbox of checkboxes) {
            this.removeSingleProduct(checkbox)
        }
        this.notifyDependentControllers()
        this.changeProductsCounterHeading()
    }

    removeSingleProduct(checkbox) {
        if (!checkbox.checked) return;
        const productId = checkbox.dataset.productId
        this.removeProductId(productId)
        checkbox.closest(".yavolos--product-item").remove()
        this.removeAssociationFromDatabaseIfPresent(productId)
    }

    removeAssociationFromDatabaseIfPresent(productId) {
        if(!this.bundleId) return;
        const url = this.removeAssociationUrl
        const data = {
            bundle_id: this.bundleId,
            product_id: productId
        }
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        })
            .then(response => response.json())
            .then(data => {
                console.log(data)
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    changeProductsCounterHeading() {
        const controllerThis = this
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

    get bundleId() {
        return this.data.get("bundle-id")
    }

    get removeAssociationUrl() {
        return this.data.get("remove-association-url")
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