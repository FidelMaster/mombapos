import { Controller } from "@hotwired/stimulus"

// Modal basado en <dialog> nativo (Esc y foco accesibles por defecto).
// Uso: data-controller="modal" + data-modal-target="dialog"; open/close como acciones.
// data-modal-open-value="true" abre el modal al conectar (p.ej. tras un error de validación).
export default class extends Controller {
  static targets = ["dialog"]
  static values = { open: Boolean }

  connect() {
    if (this.openValue) this.open()
  }

  open(event) {
    event?.preventDefault()
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
    const firstInput = this.dialogTarget.querySelector("[autofocus], input:not([type=hidden]), select, textarea")
    firstInput?.focus()
  }

  close(event) {
    event?.preventDefault()
    this.dialogTarget.close()
  }

  // Cierra al hacer clic en el backdrop.
  backdropClose(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
