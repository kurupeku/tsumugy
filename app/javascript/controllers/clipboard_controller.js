import { Controller } from "@hotwired/stimulus"

// Copies text to clipboard when triggered
// Usage: data-controller="clipboard" data-clipboard-text-value="text to copy"
export default class extends Controller {
  static values = { text: String }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      // Show feedback by temporarily changing button text
      const originalText = this.element.textContent
      this.element.textContent = "コピーしました"
      this.element.classList.add("btn-success")

      setTimeout(() => {
        this.element.textContent = originalText
        this.element.classList.remove("btn-success")
      }, 1500)
    })
  }
}
