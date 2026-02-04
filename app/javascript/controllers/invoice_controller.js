import { Controller } from "@hotwired/stimulus"

//IF INVOICE PAYMENT IS CREDIT HIDE PAYMENT METHODS
export default class extends Controller {
    static targets = [
        "item", "product", "quantity", "price", "lineTotal",
        "subtotal", "tax", "total", "tendered", "change",
        "invoiceType", "priceList", "itemsContainer", "template",
        "subtotalInput", "taxInput", "totalInput",
        "paymentsContainer", "paymentItem", "paymentMethodId", "paymentCurrency",
        "paymentAmount", "paymentExchangeRate", "paymentNioAmount", "paymentConversionDisplay",
        "paymentCurrencySymbol", "totalPaid", "pendingAmount", "invoiceTotal"
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
        // Setup for all existing payment items
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

                // Remove active state from all buttons in this payment item
                buttons.forEach(b => {
                    b.classList.remove('border-orange-500')
                    b.classList.add('border-slate-200')
                    b.querySelector('svg').classList.remove('text-orange-600')
                    b.querySelector('svg').classList.add('text-slate-400')
                    b.querySelector('span').classList.remove('text-orange-600')
                    b.querySelector('span').classList.add('text-slate-400')
                })

                // Add active state to clicked button
                btn.classList.add('border-orange-500')
                btn.classList.remove('border-slate-200')
                btn.querySelector('svg').classList.add('text-orange-600')
                btn.querySelector('svg').classList.remove('text-slate-400')
                btn.querySelector('span').classList.add('text-orange-600')
                btn.querySelector('span').classList.remove('text-slate-400')

                // Update hidden input
                if (hiddenInput) {
                    hiddenInput.value = btn.dataset.paymentMethodId
                }
            })
        })
    }

    updatePrice(event) {
        const row = event.target.closest("tr") || event.target.closest('[data-invoice-target="item"]')
        const productId = event.target.value
        const priceListId = this.hasPriceListTarget ? this.priceListTarget.value : 0

        // Get price from map: priceMap[priceListId][productId]
        let price = 0
        if (this.priceMapValue[priceListId] && this.priceMapValue[priceListId][productId]) {
            price = parseFloat(this.priceMapValue[priceListId][productId])
        } else if (this.priceMapValue[0] && this.priceMapValue[0][productId]) {
            // Fallback to base product price
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
                // Manually trigger price update for each row
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

        // Manual query to ensure we catch all inputs including newly added ones
        const inputs = this.element.querySelectorAll('[data-invoice-target="lineTotalInput"]')
        inputs.forEach(target => {
            subtotal += parseFloat(target.value) || 0
        })

        const total = subtotal
        // Task 5: Use 0 for tax (VAT omitted)
        const tax = 0
        const grandTotal = subtotal + tax

        // Updates Displays
        if (this.hasSubtotalTarget) this.subtotalTarget.textContent = subtotal.toFixed(2)
        if (this.hasTaxTarget) this.taxTarget.textContent = tax.toFixed(2)
        if (this.hasTotalTarget) this.totalTarget.textContent = grandTotal.toFixed(2)

        // Update Hidden Inputs
        if (this.hasSubtotalInputTarget) this.subtotalInputTarget.value = subtotal.toFixed(2)
        if (this.hasTaxInputTarget) this.taxInputTarget.value = tax.toFixed(2)
        if (this.hasTotalInputTarget) this.totalInputTarget.value = grandTotal.toFixed(2)

        this.calculateChange()
        this.updatePaymentSummary()
    }

    calculateChange() {
        if (!this.hasTenderedTarget || !this.hasChangeTarget || !this.hasTotalTarget) return

        const total = parseFloat(this.totalTarget.textContent) || 0
        const tendered = parseFloat(this.tenderedTarget.value) || 0

        // Verificar si existe invoiceTypeTarget antes de usarlo
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
        if (this.itemTargets.length > 1) {
            row.remove()
            this.calculateTotals()
        } else {
            row.querySelectorAll("input").forEach(input => input.value = "")
            this.calculateTotals()
        }
    }

    // Payment Methods
    addPayment(event) {
        event.preventDefault()

        // Clone the first payment item as template
        const firstPayment = this.paymentItemTargets[0]
        if (!firstPayment) return

        const clone = firstPayment.cloneNode(true)
        const timestamp = new Date().getTime()

        // Get the exchange rate value before clearing
        const exchangeRateInput = clone.querySelector('[data-invoice-target="paymentExchangeRate"]')
        const exchangeRateValue = exchangeRateInput ? exchangeRateInput.value : '1'

        // Update all name attributes to use new timestamp
        clone.querySelectorAll('input, select').forEach(input => {
            if (input.name) {
                input.name = input.name.replace(/\[\d+\]/, `[${timestamp}]`)

                // Clear values EXCEPT for exchange_rate and paymentMethodId
                const target = input.getAttribute('data-invoice-target')
                if (target !== 'paymentExchangeRate' && target !== 'paymentMethodId') {
                    input.value = ''
                }
            }
        })

        // Restore exchange rate value
        if (exchangeRateInput) {
            exchangeRateInput.value = exchangeRateValue
            console.log('Cloned payment with exchange_rate:', exchangeRateValue)
        }

        // Reset currency to NIO
        const currencySelect = clone.querySelector('[data-invoice-target="paymentCurrency"]')
        if (currencySelect) {
            currencySelect.value = 'NIO'
        }

        // Reset currency symbol to NIO
        const currencySymbol = clone.querySelector('[data-invoice-target="paymentCurrencySymbol"]')
        if (currencySymbol) {
            currencySymbol.textContent = 'C$'
        }

        // Reset to first payment method
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

                // Update hidden input with the first payment method ID
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

        // Hide conversion display
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

        // Update currency symbol
        if (currencySymbol) {
            currencySymbol.textContent = currency === 'USD' ? '$' : 'C$'
        }

        // Show/hide conversion display
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
        // Verificar que existan todos los targets necesarios
        if (!this.hasTotalPaidTarget || !this.hasPendingAmountTarget) {
            console.warn('Missing payment summary targets')
            return
        }

        // Obtener el total de la factura - buscar el total correcto (el del resumen de totales)
        let invoiceTotal = 0
        if (this.hasTotalTarget) {
            // Puede haber múltiples elementos con este target, usar el primero
            const totalElements = this.element.querySelectorAll('[data-invoice-target="total"]')
            if (totalElements.length > 0) {
                // Usar el último elemento que es el del resumen de totales
                invoiceTotal = parseFloat(totalElements[totalElements.length - 1].textContent) || 0
            }
        }

        let totalPaid = 0

        // Calculate total paid in NIO
        this.paymentItemTargets.forEach(paymentItem => {
            const currencySelect = paymentItem.querySelector('[data-invoice-target="paymentCurrency"]')
            const amountInput = paymentItem.querySelector('[data-invoice-target="paymentAmount"]')
            const exchangeRateInput = paymentItem.querySelector('[data-invoice-target="paymentExchangeRate"]')

            if (!currencySelect || !amountInput) return

            const currency = currencySelect.value
            const amount = parseFloat(amountInput.value) || 0
            const exchangeRate = parseFloat(exchangeRateInput?.value) || 1

            console.log('Payment calculation:', {
                currency,
                amount,
                exchangeRate,
                amountInput: amountInput.value,
                exchangeRateInput: exchangeRateInput?.value
            })

            // Convert to NIO ONLY if USD, NIO stays as is
            let amountInNio = amount
            if (currency === 'USD') {
                amountInNio = amount * exchangeRate
                console.log(`USD ${amount} * ${exchangeRate} = NIO ${amountInNio}`)
            } else {
                console.log(`NIO ${amount} (no conversion)`)
            }

            totalPaid += amountInNio
        })

        const pending = invoiceTotal - totalPaid

        console.log('Payment Summary:', {
            invoiceTotal,
            totalPaid,
            pending
        })


        this.totalPaidTarget.textContent = totalPaid.toFixed(2)
        this.pendingAmountTarget.textContent = `C$ ${pending.toFixed(2)}`

        // Update pending amount color
        if (pending > 0.01) { // Small tolerance for floating point
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
