import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["basePrice", "priceListItem", "typeSelect", "costContainer", "priceContainer", "stockContainer", "warehouseStockContainer", "supplierContainer"]

    connect() {
        this.syncPrices()
        this.toggleFields()
    }

    toggleFields() {
        const type = this.typeSelectTarget.value

        // VISIBILITY RULES
        // ==========================================

        // Stock, U/M and Supplier: raw_material / finished_product
        const showInventory = (type === 'raw_material' || type === 'finished_product')

        // Cost: raw_material / finished_product
        const showCost = (type === 'raw_material' || type === 'finished_product' || type === 'service')

        // Price: service / kit / finished_product
        const showPrice = (type === 'service' || type === 'kit' || type === 'finished_product')

        // APPLY VISIBILITY
        // ------------------------------------------
        this.toggleElement(this.stockContainerTarget, showInventory)
        this.toggleElement(this.warehouseStockContainerTarget, showInventory)
        this.toggleElement(this.supplierContainerTarget, showInventory)

        if (this.hasCostContainerTarget) {
            this.toggleElement(this.costContainerTarget, showCost)
        }

        if (this.hasPriceContainerTarget) {
            this.toggleElement(this.priceContainerTarget, showPrice)
        }
    }

    toggleElement(element, show) {
        if (show) {
            element.classList.remove('hidden')
        } else {
            element.classList.add('hidden')
        }
    }

    syncPrices() {
        if (!this.hasBasePriceTarget) return
        const basePrice = parseFloat(this.basePriceTarget.value) || 0
        this.priceListItemTargets.forEach(input => {
            if (input.value === "" || input.value === "0.0" || input.value === "0") {
                input.value = basePrice.toFixed(2)
            }
        })
    }

    updatePriceList(event) {
        const basePrice = parseFloat(event.target.value) || 0
        this.priceListItemTargets.forEach(input => {
            input.value = basePrice.toFixed(2)
        })
    }
}
