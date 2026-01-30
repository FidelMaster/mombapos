import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["price", "maxStudents", "totalIncomes"]

    connect() {
        this.calculate()
    }

    calculate() {
        const price = parseFloat(this.priceTarget.value) || 0
        const students = parseInt(this.maxStudentsTarget.value) || 0
        const total = price * students

        this.totalIncomesTarget.value = total.toFixed(2)
    }
}
