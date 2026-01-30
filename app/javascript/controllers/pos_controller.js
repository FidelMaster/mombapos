import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pos"
export default class extends Controller {
    static targets = ["productGrid", "receiptItems", "totalAmount", "itemCount", "categoryButton", "checkoutButton", "orderSidebar", "totalAmountMobile", "itemCountMobile", "customerName"]
    static values = {
        orderId: Number,
        tableId: Number,
        customerId: Number,
        orderType: String
    }

    connect() {
        this.orderItems = []
        this.loadActiveOrder()
    }

    toggleOrder() {
        this.orderSidebarTarget.classList.toggle('translate-x-full')
    }

    syncCustomerName(event) {
        const newValue = event.target.value
        this.customerNameTargets.forEach(target => {
            if (target !== event.target) {
                target.value = newValue
            }
        })
    }

    async loadActiveOrder() {
        if (this.orderIdValue) {
            // Show loading state in receipt
            this.receiptItemsTarget.innerHTML = `
        <div class="h-full flex flex-col items-center justify-center text-center p-8">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mb-4"></div>
          <p class="text-gray-500 font-medium">Cargando comanda...</p>
        </div>
      `

            try {
                const response = await fetch(`/orders/${this.orderIdValue}.json`)
                const data = await response.json()

                this.orderItems = data.order_items.map(item => ({
                    id: item.product_id.toString(),
                    name: item.product.name,
                    price: parseFloat(item.unit_price),
                    quantity: parseInt(item.quantity),
                    lineItemId: item.id
                }))

                if (data.customer_name && this.hasCustomerNameTarget) {
                    this.customerNameTargets.forEach(target => target.value = data.customer_name)
                }

                this.renderReceipt()
            } catch (error) {
                console.error('Error loading order:', error)
                this.renderReceipt() // Fallback to empty
            }
        }
    }

    search(event) {
        const query = event.target.value.toLowerCase()
        const products = this.productGridTarget.querySelectorAll('[data-product-name]')

        products.forEach(product => {
            const name = product.dataset.productName.toLowerCase()
            if (name.includes(query)) {
                product.classList.remove('hidden')
            } else {
                product.classList.add('hidden')
            }
        })
    }

    filterCategory(event) {
        const categoryId = event.currentTarget.dataset.categoryId

        // UI Update: Active state
        this.categoryButtonTargets.forEach(btn => {
            btn.classList.remove('bg-primary', 'text-white')
            btn.classList.add('bg-white', 'text-gray-600')
        })
        event.currentTarget.classList.add('bg-primary', 'text-white')
        event.currentTarget.classList.remove('bg-white', 'text-gray-600')

        // Filter products
        const products = this.productGridTarget.querySelectorAll('[data-product-category-id]')
        products.forEach(product => {
            if (categoryId === 'all' || product.dataset.productCategoryId === categoryId) {
                product.classList.remove('hidden')
            } else {
                product.classList.add('hidden')
            }
        })
    }

    addItem(event) {
        const button = event.currentTarget
        const product = {
            id: button.dataset.productId,
            name: button.dataset.productName,
            price: parseFloat(button.dataset.productPrice),
            quantity: 1
        }

        const existingItem = this.orderItems.find(item => item.id === product.id)
        if (existingItem) {
            existingItem.quantity += 1
        } else {
            this.orderItems.push(product)
        }

        this.renderReceipt()
        this.showSuccessFeedback(button)
    }

    removeItem(event) {
        const productId = event.currentTarget.dataset.productId
        this.orderItems = this.orderItems.filter(item => item.id !== productId)
        this.renderReceipt()
    }

    updateQuantity(event) {
        const productId = event.currentTarget.dataset.productId
        const delta = parseInt(event.currentTarget.dataset.delta)
        const item = this.orderItems.find(item => item.id === productId)

        if (item) {
            item.quantity += delta
            if (item.quantity <= 0) {
                this.orderItems = this.orderItems.filter(i => i.id !== productId)
            }
            this.renderReceipt()
        }
    }

    renderReceipt() {
        this.receiptItemsTarget.innerHTML = ''
        let total = 0
        let count = 0

        this.orderItems.forEach(item => {
            const subtotal = item.price * item.quantity
            total += subtotal
            count += item.quantity

            const html = `
        <div class="flex items-center justify-between p-4 bg-white rounded-xl shadow-sm border border-gray-100 animate-fade-in-down mb-2">
          <div class="flex-1">
            <h4 class="font-bold text-gray-800">${item.name}</h4>
            <p class="text-sm text-gray-500">${this.formatCurrency(item.price)} x ${item.quantity}</p>
          </div>
          <div class="flex items-center gap-3">
            <div class="flex items-center bg-gray-100 rounded-lg p-1">
              <button data-action="click->pos#updateQuantity" data-product-id="${item.id}" data-delta="-1" class="w-8 h-8 flex items-center justify-center text-gray-600 hover:bg-white rounded-md transition-colors">-</button>
              <span class="w-8 text-center font-bold">${item.quantity}</span>
              <button data-action="click->pos#updateQuantity" data-product-id="${item.id}" data-delta="1" class="w-8 h-8 flex items-center justify-center text-gray-600 hover:bg-white rounded-md transition-colors">+</button>
            </div>
            <div class="text-right min-w-[80px]">
              <span class="font-bold text-gray-900">${this.formatCurrency(subtotal)}</span>
            </div>
          </div>
        </div>
      `
            this.receiptItemsTarget.insertAdjacentHTML('beforeend', html)
        })

        this.totalAmountTarget.textContent = this.formatCurrency(total)
        this.itemCountTarget.textContent = `${count} ítems`

        if (this.hasTotalAmountMobileTarget) {
            this.totalAmountMobileTarget.textContent = this.formatCurrency(total)
        }
        if (this.hasItemCountMobileTarget) {
            this.itemCountMobileTarget.textContent = count
        }
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('es-NI', { style: 'currency', currency: 'NIO' }).format(amount)
    }

    showSuccessFeedback(button) {
        const originalContent = button.innerHTML
        button.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>'
        button.classList.add('bg-green-500')

        setTimeout(() => {
            button.innerHTML = originalContent
            button.classList.remove('bg-green-500')
        }, 500)
    }

    async checkout(event) {
        // We save first to ensure DB is up to date, then we go to invoice
        this.shouldRedirectToInvoice = true
        await this.saveOrder()
    }

    cancel(event) {
        window.location.href = '/pos'
    }

    async saveOrder() {
        if (this.orderItems.length === 0) return

        this.shouldRedirectToInvoice = this.shouldRedirectToInvoice || false

        const isExisting = !!this.orderIdValue
        const url = isExisting ? `/orders/${this.orderIdValue}` : '/orders'
        const method = isExisting ? 'PATCH' : 'POST'

        const data = {
            order: {
                dining_table_id: this.tableIdValue || null,
                customer_id: this.customerIdValue,
                order_type: this.orderTypeValue || null,
                customer_name: this.hasCustomerNameTarget ? this.customerNameTarget.value : null,
                order_items_attributes: this.orderItems.map(item => ({
                    id: item.lineItemId || null,
                    product_id: item.id,
                    quantity: item.quantity,
                    unit_price: item.price,
                    subtotal: item.price * item.quantity
                }))
            }
        }

        try {
            const response = await fetch(url, {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
                },
                body: JSON.stringify(data)
            })

            if (response.ok) {
                const orderData = await response.json()
                if (this.shouldRedirectToInvoice) {
                    window.location.href = `/invoices/new?order_id=${orderData.id}`
                } else {
                    window.location.href = '/pos'
                }
            } else {
                const errorData = await response.json()
                alert('Error al guardar la orden: ' + JSON.stringify(errorData))
            }
        } catch (error) {
            console.error('Error:', error)
            alert('Error de conexión al servidor')
        }
    }
}
