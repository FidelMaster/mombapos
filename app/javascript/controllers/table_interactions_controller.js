import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form"]

    submit(event) {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            this.formTarget.requestSubmit()
        }, 400) // Debounce for 400ms
    }

    change(event) {
        this.formTarget.requestSubmit()
    }
}
