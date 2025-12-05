import { Controller } from "@hotwired/stimulus"

// Game detail modal controller
// Opens modal on card click, closes on cancel/backdrop click
//
// Usage:
//   <div data-controller="game-modal">
//     <button data-action="click->game-modal#open">Open</button>
//     <dialog data-game-modal-target="dialog">...</dialog>
//   </div>
export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  backdropClick(event) {
    // Close only if clicking the dialog backdrop (not the modal-box)
    if (event.target === this.dialogTarget) {
      this.dialogTarget.close()
    }
  }
}
