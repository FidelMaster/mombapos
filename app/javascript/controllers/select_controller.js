import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        new TomSelect(this.element, {
            dropdownParent: 'body',
            create: false,
            sortField: {
                field: "text",
                direction: "asc"
            }
        });
    }
}
