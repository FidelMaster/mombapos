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
      this.accountsListTarget.innerHTML = `
                <div class="text-center py-12">
                    <div class="w-16 h-16 bg-emerald-50 rounded-full flex items-center justify-center mb-4 mx-auto">
                        <svg class="w-8 h-8 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                    </div>
                    <p class="text-sm font-black text-emerald-600 uppercase tracking-widest">¡Excelente! El cliente no tiene deudas</p>
                </div>`
      this.totalBalanceTarget.textContent = "C$ 0.00"
      return
    }

    let total = 0
    let html = `
      <div class="overflow-hidden rounded-2xl border border-gray-100 bg-white">
        <table class="min-w-full divide-y divide-gray-100">
          <thead class="bg-gray-50/50">
            <tr>
              <th class="px-6 py-4 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">Documento</th>
              <th class="px-6 py-4 text-left text-[10px] font-black text-gray-400 uppercase tracking-widest">Fecha</th>
              <th class="px-6 py-4 text-right text-[10px] font-black text-gray-400 uppercase tracking-widest">Monto Original</th>
              <th class="px-6 py-4 text-right text-[10px] font-black text-gray-400 uppercase tracking-widest">Saldo Pendiente</th>
              <th class="px-6 py-4"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
    `

    accounts.forEach(acc => {
      total += parseFloat(acc.balance)
      html += `
        <tr class="hover:bg-gray-50 transition-colors group">
          <td class="px-6 py-4">
            <span class="text-sm font-black text-gray-900 tracking-tight">${acc.invoice_number || 'S/N'}</span>
          </td>
          <td class="px-6 py-4 text-sm font-bold text-gray-400 font-mono">${acc.date}</td>
          <td class="px-6 py-4 text-sm font-bold text-gray-700 text-right font-mono italic">C$ ${acc.original_amount}</td>
          <td class="px-6 py-4 text-right">
            <span class="text-base font-black text-red-500 font-mono italic">C$ ${acc.balance}</span>
          </td>
          <td class="px-6 py-4 text-right">
            <button type="button" 
                    class="px-4 py-2 bg-primary-100 text-primary hover:bg-primary hover:text-white transition-all rounded-xl text-xs font-black uppercase tracking-widest"
                    data-action="click->receipt#autoFill" 
                    data-account-id="${acc.id}" 
                    data-balance="${acc.balance}">
              Seleccionar
            </button>
          </td>
        </tr>
      `
    })

    html += `</tbody></table></div>`
    this.accountsListTarget.className = "w-full"
    this.accountsListTarget.innerHTML = html
    this.totalBalanceTarget.textContent = `C$ ${total.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
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
