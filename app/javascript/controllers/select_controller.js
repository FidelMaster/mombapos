import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        new TomSelect(this.element, {
            create: false,
            sortField: {
                field: "text",
                direction: "asc"
            }
        });
    }
}
