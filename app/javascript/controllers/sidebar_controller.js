import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["sidebar", "overlay"]

    connect() {
        // Initial setup if needed
    }

    toggle() {
        this.sidebarTarget.classList.toggle("-translate-x-full")
        if (this.overlayTarget) {
            this.overlayTarget.classList.toggle("hidden")
        }
    }

    close() {
        this.sidebarTarget.classList.add("-translate-x-full")
        if (this.overlayTarget) {
            this.overlayTarget.classList.add("hidden")
        }
    }
}
