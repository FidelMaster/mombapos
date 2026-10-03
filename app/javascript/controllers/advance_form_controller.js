import { Controller } from "@hotwired/stimulus"

// Formulario de anticipos: muestra cuenta bancaria solo en métodos que la requieren
// y permite liquidar el saldo con un clic.
export default class extends Controller {
  static targets = ["amount", "method", "bankSection", "bankSelect", "preview"]
  static values = { balance: Number, currency: String }

  connect() {
    this.formatter = new Intl.NumberFormat("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    this.methodChanged()
    this.amountChanged()
  }

  methodChanged() {
    const selected = this.methodTargets.find((input) => input.checked)
    const requiresBank = selected?.dataset.requiresBank === "true"
    this.bankSectionTarget.classList.toggle("hidden", !requiresBank)
    this.bankSelectTarget.required = requiresBank
    if (!requiresBank) this.bankSelectTarget.value = ""
  }

  fillBalance(event) {
    event.preventDefault()
    this.amountTarget.value = this.balanceValue.toFixed(2)
    this.amountChanged()
  }

  amountChanged() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const remaining = this.balanceValue - amount
    if (!this.hasPreviewTarget) return

    if (amount > this.balanceValue + 0.001) {
      this.previewTarget.className = "text-xs font-bold text-rose-600"
      this.previewTarget.textContent = `Excede el saldo por ${this.money(amount - this.balanceValue)}`
    } else if (amount > 0) {
      this.previewTarget.className = "text-xs font-semibold text-slate-500"
      this.previewTarget.textContent = remaining <= 0.001
        ? "✓ Con este abono el pedido queda liquidado"
        : `Saldo después del abono: ${this.money(remaining)}`
    } else {
      this.previewTarget.textContent = ""
    }
  }

  money(amount) {
    return `${this.currencyValue} ${this.formatter.format(amount)}`
  }
}
