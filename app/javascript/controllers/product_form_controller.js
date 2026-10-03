import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "basePrice", "priceListItem", "typeSelect", "costContainer",
        "priceContainer", "stockContainer", "warehouseStockContainer",
        "supplierContainer", "imagePreview", "imagePlaceholder",
        "variantsContainer", "variantTemplate"
    ]

    connect() {
        this.syncPrices()
        this.toggleFields()
    }

    toggleFields() {
        const type = this.typeSelectTarget.value

        // VISIBILITY RULES
        // ==========================================
        const showInventory = (type === 'raw_material' || type === 'finished_product')
        const showCost = (type === 'raw_material' || type === 'finished_product' || type === 'service')
        const showPrice = (type === 'service' || type === 'kit' || type === 'finished_product')

        this.toggleElement(this.warehouseStockContainerTarget, showInventory)

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

    // Image preview
    previewImage(event) {
        const input = event.target
        if (input.files && input.files[0]) {
            const reader = new FileReader()
            reader.onload = (e) => {
                if (this.hasImagePreviewTarget) {
                    this.imagePreviewTarget.src = e.target.result
                    this.imagePreviewTarget.classList.remove('hidden')
                }
                if (this.hasImagePlaceholderTarget) {
                    this.imagePlaceholderTarget.classList.add('hidden')
                }
            }
            reader.readAsDataURL(input.files[0])
        }
    }

    // Dynamic product variants
    addVariant(event) {
        event.preventDefault()
        if (!this.hasVariantsContainerTarget || !this.hasVariantTemplateTarget) return
        const uniqueId = new Date().getTime()
        const content = this.variantTemplateTarget.innerHTML.replace(/NEW_VARIANT_RECORD/g, uniqueId)
        this.variantsContainerTarget.insertAdjacentHTML('beforeend', content)
    }

    removeVariant(event) {
        event.preventDefault()
        const row = event.target.closest('[data-role="variant-row"]')
        if (!row) return
        const destroyInput = row.querySelector('input[name*="[_destroy]"]')
        if (destroyInput) {
            destroyInput.value = "1"
            row.style.display = "none"
        } else {
            row.remove()
        }
    }
}
