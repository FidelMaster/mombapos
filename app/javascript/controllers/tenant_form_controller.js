import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["imagePreview", "imagePlaceholder"]

  previewLogo(event) {
    const input = event.target
    if (input.files && input.files[0]) {
      const reader = new FileReader()
      reader.onload = (e) => {
        if (this.hasImagePreviewTarget) {
          this.imagePreviewTarget.src = e.target.result
          this.imagePreviewTarget.classList.remove("hidden")
        }
        if (this.hasImagePlaceholderTarget) {
          this.imagePlaceholderTarget.classList.add("hidden")
        }
      }
      reader.readAsDataURL(input.files[0])
    }
  }
}
