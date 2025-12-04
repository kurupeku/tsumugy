import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Drag-and-drop sortable list controller
// Usage: data-controller="sortable" data-sortable-url-value="/path/to/update"
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      ghostClass: "opacity-50",
      handle: "[data-sortable-item]",
      draggable: "[data-sortable-item]",
      onEnd: this.handleEnd.bind(this)
    })
  }

  handleEnd(event) {
    // Update rank numbers visually
    this.updateRankDisplay()

    // Save to server
    this.saveRankings()
  }

  updateRankDisplay() {
    const items = this.element.querySelectorAll("[data-sortable-item]")
    items.forEach((item, index) => {
      const rankBadge = item.querySelector("[data-rank]")
      if (rankBadge) {
        rankBadge.textContent = index + 1
      }
    })
  }

  saveRankings() {
    const itemIds = Array.from(this.element.querySelectorAll("[data-item-id]"))
      .map(el => el.dataset.itemId)

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ rankings: itemIds })
    }).catch(error => {
      console.error("Failed to save rankings:", error)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }
}
