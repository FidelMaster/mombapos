import { Controller } from "@hotwired/stimulus"

// IF INVOICE PAYMENT IS CREDIT HIDE PAYMENT METHODS
export default class extends Controller {
    static targets = [
        "item", "product", "quantity", "price", "lineTotal",
        "subtotal", "tax", "total", "tendered", "change",
        "invoiceType", "priceList", "itemsContainer", "template",
        "subtotalInput", "taxInput", "totalInput",
        "paymentsContainer", "paymentItem", "paymentMethodId", "paymentCurrency",
        "paymentAmount", "paymentExchangeRate", "paymentNioAmount", "paymentConversionDisplay",
        "paymentCurrencySymbol", "totalPaid", "pendingAmount", "invoiceTotal",
        "exchangeRateInput", "totalUsd", "ticketTotalUsd", "ticketSubtotal", "ticketTotal", "ticketItemsContainer"
    ]
    static values = {
        products: Array,
        priceMap: Object
    }

    connect() {
        this.itemTargets.forEach(row => {
            this.calculateLineTotal(row)
        })
        this.calculateTotals()
        this.togglePaymentInfo()
        this.setupPaymentMethodButtons()
        this.updatePaymentSummary()
    }

    togglePaymentInfo() {
        const selectedType = this.element.querySelector('input[name="invoice[invoice_type]"]:checked')?.value || 'cash'
        const paymentInfo = this.paymentsContainerTarget

        if (selectedType === 'credit') {
            paymentInfo.classList.add('hidden')
        } else {
            paymentInfo.classList.remove('hidden')
        }

        this.calculateChange()
    }

    setupPaymentMethodButtons() {
        this.paymentItemTargets.forEach(paymentItem => {
            this.setupPaymentMethodButtonsForItem(paymentItem)
        })
    }

    setupPaymentMethodButtonsForItem(paymentItem) {
        const buttons = paymentItem.querySelectorAll('.payment-method-btn')
        const hiddenInput = paymentItem.querySelector('[data-invoice-target="paymentMethodId"]')

        buttons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault()

                buttons.forEach(b => {
                    b.classList.remove('border-orange-500')
                    b.classList.add('border-slate-200')
                    b.querySelector('svg').classList.remove('text-orange-600')
                    b.querySelector('svg').classList.add('text-slate-400')
                    b.querySelector('span').classList.remove('text-orange-600')
                    b.querySelector('span').classList.add('text-slate-400')
                })

                btn.classList.add('border-orange-500')
                btn.classList.remove('border-slate-200')
                btn.querySelector('svg').classList.add('text-orange-600')
                btn.querySelector('svg').classList.remove('text-slate-400')
                btn.querySelector('span').classList.add('text-orange-600')
                btn.querySelector('span').classList.remove('text-slate-400')

                if (hiddenInput) {
                    hiddenInput.value = btn.dataset.paymentMethodId
                }
            })
        })
    }

    updatePrice(event) {
        const row = event.target.closest("tr") || event.target.closest('[data-invoice-target="item"]')
        const productSelect = row.querySelector('[data-invoice-target="product"]')
        const productId = productSelect ? productSelect.value : ''
        const priceListId = this.hasPriceListTarget ? this.priceListTarget.value : 0

        // 1. Guardar la descripción/nombre del producto en el input hidden de la línea
        const descriptionInput = row.querySelector('[data-invoice-target="itemDescriptionInput"]')
        if (descriptionInput && productSelect && productSelect.selectedIndex >= 0) {
            const selectedOption = productSelect.options[productSelect.selectedIndex]
            descriptionInput.value = selectedOption ? selectedOption.text.trim() : ''
        }

        // 2. Obtener precio desde la lista de precios
        let price = 0
        if (this.priceMapValue[priceListId] && this.priceMapValue[priceListId][productId]) {
            price = parseFloat(this.priceMapValue[priceListId][productId])
        } else if (this.priceMapValue[0] && this.priceMapValue[0][productId]) {
            price = parseFloat(this.priceMapValue[0][productId])
        }

        const priceField = row.querySelector('[data-invoice-target="price"]')
        if (priceField) {
            priceField.value = price.toFixed(2)
        }

        this.calculateLineTotal(row)
    }

    updateAllPrices() {
        this.productTargets.forEach(productSelect => {
            if (productSelect.value) {
                this.updatePrice({ target: productSelect })
            }
        })
    }

    updateQuantity(event) {
        const row = event.target.closest("tr") || event.target.closest('[data-invoice-target="item"]')
        this.calculateLineTotal(row)
    }

    calculateLineTotal(row) {
        const qtyField = row.querySelector('[data-invoice-target="quantity"]')
        const priceField = row.querySelector('[data-invoice-target="price"]')
        const totalElement = row.querySelector('[data-invoice-target="lineTotal"]')
        const totalInput = row.querySelector('[data-invoice-target="lineTotalInput"]') || row.querySelector('input[name*="[total]"]')

        const qty = parseFloat(qtyField.value) || 0
        const currentPrice = parseFloat(priceField.value) || 0

        const total = qty * currentPrice

        if (totalElement) {
            totalElement.textContent = total.toFixed(2)
        }

        if (totalInput) {
            totalInput.value = total.toFixed(2)
        }

        this.calculateTotals()
    }

    calculateTotals() {
        let subtotal = 0

        const inputs = this.element.querySelectorAll('[data-invoice-target="lineTotalInput"]')
        inputs.forEach(target => {
            subtotal += parseFloat(target.value) || 0
        })

        const tax = 0
        const grandTotal = subtotal + tax

        // Obtener tipo de cambio activo
        const exchangeRate = parseFloat(this.hasExchangeRateInputTarget ? this.exchangeRateInputTarget.value : 1.0) || 1.0

        // Calcular Total USD
        const totalUsd = exchangeRate > 0 ? (grandTotal / exchangeRate) : 0

        // Actualizar UI del Formulario Principal
        if (this.hasSubtotalTarget) this.subtotalTarget.textContent = subtotal.toFixed(2)
        if (this.hasTaxTarget) this.taxTarget.textContent = tax.toFixed(2)
        if (this.hasTotalTarget) this.totalTarget.textContent = grandTotal.toFixed(2)
        if (this.hasTotalUsdTarget) this.totalUsdTarget.textContent = totalUsd.toFixed(2)

        // Actualizar UI del Ticket Modal 80mm
        if (this.hasTicketSubtotalTarget) this.ticketSubtotalTarget.textContent = subtotal.toFixed(2)
        if (this.hasTicketTotalTarget) this.ticketTotalTarget.textContent = grandTotal.toFixed(2)
        if (this.hasTicketTotalUsdTarget) this.ticketTotalUsdTarget.textContent = totalUsd.toFixed(2)

        // Actualizar Hidden Inputs para la base de datos
        if (this.hasSubtotalInputTarget) this.subtotalInputTarget.value = subtotal.toFixed(2)
        if (this.hasTaxInputTarget) this.taxInputTarget.value = tax.toFixed(2)
        if (this.hasTotalInputTarget) this.totalInputTarget.value = grandTotal.toFixed(2)

        this.updateTicketItemsModal()
        this.calculateChange()
        this.updatePaymentSummary()
    }

    updateTicketItemsModal() {
        if (!this.hasTicketItemsContainerTarget) return

        let html = ''
        let hasRows = false

        this.element.querySelectorAll('[data-invoice-target="item"]').forEach(row => {
            const productSelect = row.querySelector('[data-invoice-target="product"]')
            const qtyInput = row.querySelector('[data-invoice-target="quantity"]')
            const totalInput = row.querySelector('[data-invoice-target="lineTotalInput"]')
            const destroyInput = row.querySelector('input[name*="[_destroy]"]')

            // Ignorar filas marcadas para eliminar
            if (destroyInput && destroyInput.value === '1') return

            if (productSelect && productSelect.selectedIndex >= 0 && productSelect.value) {
                hasRows = true
                const productName = productSelect.options[productSelect.selectedIndex].text.split(' - ')[0] // Toma el nombre limpio
                const qty = qtyInput ? qtyInput.value : 1
                const total = totalInput ? parseFloat(totalInput.value).toFixed(2) : '0.00'

                html += `
                    <div class="grid grid-cols-12">
                        <span class="col-span-2">${qty}x</span>
                        <span class="col-span-6 truncate">${productName}</span>
                        <span class="col-span-4 text-right">C$${total}</span>
                    </div>
                `
            }
        })

        if (!hasRows) {
            html = '<div class="text-center text-slate-400 py-1">Sin productos agregados</div>'
        }

        this.ticketItemsContainerTarget.innerHTML = html
    }

    calculateChange() {
        if (!this.hasTenderedTarget || !this.hasChangeTarget || !this.hasTotalTarget) return

        const total = parseFloat(this.totalTarget.textContent) || 0
        const tendered = parseFloat(this.tenderedTarget.value) || 0

        if (this.hasInvoiceTypeTarget && this.invoiceTypeTarget.value === 'cash') {
            const change = tendered - total
            this.changeTarget.textContent = change.toFixed(2)

            if (change < 0) {
                this.changeTarget.classList.add("text-red-500")
                this.changeTarget.classList.remove("text-green-500")
            } else {
                this.changeTarget.classList.remove("text-red-500")
                this.changeTarget.classList.add("text-green-500")
            }
        } else {
            const change = tendered - total
            this.changeTarget.textContent = change.toFixed(2)
        }
    }

    addItem(event) {
        event.preventDefault()
        const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
        this.itemsContainerTarget.insertAdjacentHTML('beforeend', content)
        this.calculateTotals()
    }

    removeItem(event) {
        event.preventDefault()
        const row = event.target.closest("tr")
        const destroyInput = row.querySelector('input[name*="[_destroy]"]')

        if (destroyInput) {
            destroyInput.value = "1"
            row.style.display = "none"
        } else {
            row.remove()
        }
        this.calculateTotals()
    }

    // Payment Methods
    addPayment(event) {
        event.preventDefault()

        const firstPayment = this.paymentItemTargets[0]
        if (!firstPayment) return

        const clone = firstPayment.cloneNode(true)
        const timestamp = new Date().getTime()

        const exchangeRateInput = clone.querySelector('[data-invoice-target="paymentExchangeRate"]')
        const exchangeRateValue = exchangeRateInput ? exchangeRateInput.value : '1'

        clone.querySelectorAll('input, select').forEach(input => {
            if (input.name) {
                input.name = input.name.replace(/\[\d+\]/, `[${timestamp}]`)

                const target = input.getAttribute('data-invoice-target')
                if (target !== 'paymentExchangeRate' && target !== 'paymentMethodId') {
                    input.value = ''
                }
            }
        })

        if (exchangeRateInput) {
            exchangeRateInput.value = exchangeRateValue
        }

        const currencySelect = clone.querySelector('[data-invoice-target="paymentCurrency"]')
        if (currencySelect) {
            currencySelect.value = 'NIO'
        }

        const currencySymbol = clone.querySelector('[data-invoice-target="paymentCurrencySymbol"]')
        if (currencySymbol) {
            currencySymbol.textContent = 'C$'
        }

        const buttons = clone.querySelectorAll('.payment-method-btn')
        const hiddenMethodInput = clone.querySelector('[data-invoice-target="paymentMethodId"]')

        buttons.forEach((btn, index) => {
            if (index === 0) {
                btn.classList.add('border-orange-500')
                btn.classList.remove('border-slate-200')
                btn.querySelector('svg').classList.add('text-orange-600')
                btn.querySelector('svg').classList.remove('text-slate-400')
                btn.querySelector('span').classList.add('text-orange-600')
                btn.querySelector('span').classList.remove('text-slate-400')

                if (hiddenMethodInput) {
                    hiddenMethodInput.value = btn.dataset.paymentMethodId
                }
            } else {
                btn.classList.remove('border-orange-500')
                btn.classList.add('border-slate-200')
                btn.querySelector('svg').classList.remove('text-orange-600')
                btn.querySelector('svg').classList.add('text-slate-400')
                btn.querySelector('span').classList.remove('text-orange-600')
                btn.querySelector('span').classList.add('text-slate-400')
            }
        })

        const conversionDisplay = clone.querySelector('[data-invoice-target="paymentConversionDisplay"]')
        if (conversionDisplay) {
            conversionDisplay.classList.add('hidden')
        }

        this.paymentsContainerTarget.appendChild(clone)
        this.setupPaymentMethodButtonsForItem(clone)
        this.updatePaymentSummary()
    }

    removePayment(event) {
        event.preventDefault()

        if (this.paymentItemTargets.length > 1) {
            const paymentItem = event.target.closest('[data-invoice-target="paymentItem"]')
            paymentItem.remove()
            this.updatePaymentSummary()
        }
    }

    updatePaymentConversion(event) {
        const paymentItem = event.target.closest('[data-invoice-target="paymentItem"]')
        if (!paymentItem) return

        const currencySelect = paymentItem.querySelector('[data-invoice-target="paymentCurrency"]')
        const amountInput = paymentItem.querySelector('[data-invoice-target="paymentAmount"]')
        const exchangeRateInput = paymentItem.querySelector('[data-invoice-target="paymentExchangeRate"]')
        const nioAmountDisplay = paymentItem.querySelector('[data-invoice-target="paymentNioAmount"]')
        const conversionDisplay = paymentItem.querySelector('[data-invoice-target="paymentConversionDisplay"]')
        const currencySymbol = paymentItem.querySelector('[data-invoice-target="paymentCurrencySymbol"]')

        if (!currencySelect || !amountInput || !exchangeRateInput) return

        const currency = currencySelect.value
        const amount = parseFloat(amountInput.value) || 0
        const exchangeRate = parseFloat(exchangeRateInput.value) || 1

        if (currencySymbol) {
            currencySymbol.textContent = currency === 'USD' ? '$' : 'C$'
        }

        if (currency === 'USD') {
            const nioAmount = amount * exchangeRate
            if (nioAmountDisplay) {
                nioAmountDisplay.textContent = nioAmount.toFixed(2)
            }
            if (conversionDisplay) {
                conversionDisplay.classList.remove('hidden')
            }
        } else {
            if (conversionDisplay) {
                conversionDisplay.classList.add('hidden')
            }
        }

        this.updatePaymentSummary()
    }

    updatePaymentSummary() {
        if (!this.hasTotalPaidTarget || !this.hasPendingAmountTarget) return

        let invoiceTotal = 0
        if (this.hasTotalTarget) {
            const totalElements = this.element.querySelectorAll('[data-invoice-target="total"]')
            if (totalElements.length > 0) {
                invoiceTotal = parseFloat(totalElements[totalElements.length - 1].textContent) || 0
            }
        }

        let totalPaid = 0

        this.paymentItemTargets.forEach(paymentItem => {
            const currencySelect = paymentItem.querySelector('[data-invoice-target="paymentCurrency"]')
            const amountInput = paymentItem.querySelector('[data-invoice-target="paymentAmount"]')
            const exchangeRateInput = paymentItem.querySelector('[data-invoice-target="paymentExchangeRate"]')

            if (!currencySelect || !amountInput) return

            const currency = currencySelect.value
            const amount = parseFloat(amountInput.value) || 0
            const exchangeRate = parseFloat(exchangeRateInput?.value) || 1

            let amountInNio = amount
            if (currency === 'USD') {
                amountInNio = amount * exchangeRate
            }

            totalPaid += amountInNio
        })

        const pending = invoiceTotal - totalPaid

        this.totalPaidTarget.textContent = totalPaid.toFixed(2)
        this.pendingAmountTarget.textContent = `C$ ${pending.toFixed(2)}`

        if (pending > 0.01) {
            this.pendingAmountTarget.classList.add('text-red-600')
            this.pendingAmountTarget.classList.remove('text-green-600', 'text-orange-600')
        } else if (pending < -0.01) {
            this.pendingAmountTarget.classList.add('text-orange-600')
            this.pendingAmountTarget.classList.remove('text-red-600', 'text-green-600')
        } else {
            this.pendingAmountTarget.classList.add('text-green-600')
            this.pendingAmountTarget.classList.remove('text-red-600', 'text-orange-600')
        }
    }
}