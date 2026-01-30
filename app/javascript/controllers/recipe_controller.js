import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "template", "row"]

    connect() {
        console.log("Recipe controller connected")
        console.log("Template target:", this.hasTemplateTarget ? "Found" : "Not found")
    }

    addItem(event) {
        event.preventDefault()
        console.log("Adding item...")
        if (!this.hasTemplateTarget) {
            console.error("Template target is missing!")
            return
        }
        const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
        this.containerTarget.insertAdjacentHTML('beforeend', content)
    }

    removeItem(event) {
        event.preventDefault()
        const row = event.target.closest('[data-recipe-target="row"]')
        const destroyInput = row.querySelector('input[name*="_destroy"]')

        if (destroyInput) {
            destroyInput.value = "1"
            row.style.display = 'none'
        } else {
            row.remove()
        }
    }
}
