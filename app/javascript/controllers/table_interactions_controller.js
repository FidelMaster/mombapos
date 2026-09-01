import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form"]

    connect() {
        this.debounceTimer = null
    }

    disconnect() {
        clearTimeout(this.debounceTimer)
    }

    // Handle search input with debounce
    submit(event) {
        clearTimeout(this.debounceTimer)
        this.debounceTimer = setTimeout(() => {
            // Reset to page 1 when searching
            const form = this.formTarget
            const pageInput = form.querySelector('input[name="page"]')
            if (pageInput) pageInput.value = 1
            form.requestSubmit()
        }, 400) // 400ms debounce
    }

    // Handle filter changes (per_page, category, status, etc)
    change(event) {
        clearTimeout(this.debounceTimer)
        const form = this.formTarget
        // Reset to page 1 when changing filters
        const pageInput = form.querySelector('input[name="page"]')
        if (pageInput) pageInput.value = 1
        this.debounceTimer = setTimeout(() => {
            form.requestSubmit()
        }, 200) // 200ms for instant filter response
    }
}

