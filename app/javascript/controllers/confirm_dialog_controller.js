import { Controller } from "@hotwired/stimulus"

// Custom confirmation dialog controller using DaisyUI modal
// Usage:
//   <div data-controller="confirm-dialog" data-confirm-dialog-form-id-value="form-id">
//     <form id="form-id" class="hidden">...</form>
//     <button data-action="confirm-dialog#open">Open</button>
//     <dialog data-confirm-dialog-target="dialog">...</dialog>
//   </div>
export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    formId: String
  }

  open(event) {
    event.preventDefault()
    this.dialogTarget.showModal()
  }

  confirm() {
    this.dialogTarget.close()

    if (this.hasFormIdValue && this.formIdValue) {
      const form = document.getElementById(this.formIdValue)
      if (form) {
        form.requestSubmit()
      }
    }
  }

  cancel() {
    this.dialogTarget.close()
  }

  backdropClick(event) {
    // Close only if clicking the dialog backdrop (not the modal-box)
    if (event.target === this.dialogTarget) {
      this.dialogTarget.close()
    }
  }
}
