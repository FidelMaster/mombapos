import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["customerSelect", "accountsList", "amountInput", "totalBalance"]

    connect() {
        console.log("Receipt controller connected")
    }

    loadAccounts() {
        const customerId = this.customerSelectTarget.value
        if (!customerId) {
            this.accountsListTarget.innerHTML = '<div class="text-slate-400 text-sm text-center py-8">Seleccione un cliente para ver sus deudas</div>'
            this.totalBalanceTarget.textContent = "C$ 0.00"
            return
        }

        fetch(`/receipts/customer_accounts?customer_id=${customerId}`)
            .then(response => response.json())
            .then(accounts => {
                this.renderAccounts(accounts)
            })
    }

    renderAccounts(accounts) {
        if (accounts.length === 0) {
            this.accountsListTarget.innerHTML = '<div class="text-emerald-600 text-sm text-center py-8 font-semibold">El cliente no tiene deudas pendientes</div>'
            this.totalBalanceTarget.textContent = "C$ 0.00"
            return
        }

        let total = 0
        let html = `
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead>
            <tr>
              <th class="px-4 py-2 text-left text-xs font-bold text-slate-500 uppercase">Factura</th>
              <th class="px-4 py-2 text-left text-xs font-bold text-slate-500 uppercase">Fecha</th>
              <th class="px-4 py-2 text-right text-xs font-bold text-slate-500 uppercase">Monto Orig.</th>
              <th class="px-4 py-2 text-right text-xs font-bold text-slate-500 uppercase">Saldo Pend.</th>
              <th class="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
    `

        accounts.forEach(acc => {
            total += parseFloat(acc.balance)
            html += `
        <tr>
          <td class="px-4 py-3 text-sm text-slate-900 font-medium">${acc.invoice_number || 'S/N'}</td>
          <td class="px-4 py-3 text-sm text-slate-500">${acc.date}</td>
          <td class="px-4 py-3 text-sm text-slate-700 text-right">C$ ${acc.original_amount}</td>
          <td class="px-4 py-3 text-sm font-bold text-red-600 text-right">C$ ${acc.balance}</td>
          <td class="px-4 py-3 text-sm text-center">
            <button type="button" 
                    class="text-indigo-600 hover:text-indigo-900 font-bold"
                    data-action="click->receipt#autoFill" 
                    data-account-id="${acc.id}" 
                    data-balance="${acc.balance}">
              Abonar
            </button>
          </td>
        </tr>
      `
        })

        html += `</tbody></table></div>`
        this.accountsListTarget.innerHTML = html
        this.totalBalanceTarget.textContent = `C$ ${total.toFixed(2)}`
    }

    autoFill(event) {
        const balance = event.currentTarget.dataset.balance
        const accountId = event.currentTarget.dataset.accountId

        this.amountInputTarget.value = balance
        // Optional: set a hidden field if we want to target a specific AR record
        const hiddenField = document.getElementById('receipt_document_account_receivable_id')
        if (hiddenField) {
            hiddenField.value = accountId
        }
    }
}
