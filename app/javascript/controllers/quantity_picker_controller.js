import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  decrease() {
    const value = this.currentValue()
    this.inputTarget.value = Math.max(1, value - 1)
  }

  increase() {
    this.inputTarget.value = this.currentValue() + 1
  }

  currentValue() {
    const value = parseInt(this.inputTarget.value, 10)
    return Number.isNaN(value) || value < 1 ? 1 : value
  }
}
