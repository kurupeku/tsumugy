import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to NasaGame::SessionChannel for phase changes and dashboard updates
export default class extends Controller {
  static values = {
    sessionId: String,
    currentPhase: String,
    isFacilitator: { type: Boolean, default: false },
    terminatedTitle: { type: String, default: "セッション終了" },
    terminatedMessage: { type: String, default: "ファシリテーターがセッションを終了しました。" },
    terminatedConfirm: { type: String, default: "OK" }
  }

  connect() {
    console.log("[SessionSubscription] Connecting to session:", this.sessionIdValue)

    this.channel = createConsumer().subscriptions.create(
      {
        channel: "NasaGame::SessionChannel",
        session_id: this.sessionIdValue
      },
      {
        connected: () => {
          console.log("[SessionSubscription] Connected successfully")
        },
        disconnected: () => {
          console.log("[SessionSubscription] Disconnected")
        },
        rejected: () => {
          console.log("[SessionSubscription] Connection rejected")
        },
        received: (data) => this.handleMessage(data)
      }
    )
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }

  handleMessage(data) {
    console.log("[SessionSubscription] Received message:", data)

    switch (data.type) {
      case "phase_changed":
        this.handlePhaseChange(data)
        break
      case "participant_joined":
      case "individual_completed":
      case "team_completed":
        this.handleDashboardUpdate(data)
        break
      case "session_terminated":
        this.handleSessionTerminated()
        break
    }
  }

  handlePhaseChange(data) {
    // If phase changed, reload the page to show the new phase view
    if (data.phase !== this.currentPhaseValue) {
      window.location.reload()
    }
  }

  handleDashboardUpdate(data) {
    // Only facilitator dashboard needs these updates
    if (!this.isFacilitatorValue) return

    // Update group card if present
    if (data.group_id && data.html) {
      const groupCard = document.getElementById(`group-card-${data.group_id}`)
      if (groupCard) {
        groupCard.outerHTML = data.html
      }
    }

    // Update stats if present
    if (data.stats_html) {
      const stats = document.getElementById("session-stats")
      if (stats) {
        stats.outerHTML = data.stats_html
      }
    }
  }

  handleSessionTerminated() {
    // Facilitator is already redirected by their own action
    if (this.isFacilitatorValue) return

    this.showTerminationDialog()
  }

  showTerminationDialog() {
    // Create DaisyUI modal dynamically
    const dialog = document.createElement("dialog")
    dialog.className = "modal modal-open"
    dialog.innerHTML = `
      <div class="modal-box">
        <h3 class="font-bold text-lg">${this.terminatedTitleValue}</h3>
        <p class="py-4">${this.terminatedMessageValue}</p>
        <div class="modal-action">
          <button class="btn btn-primary" id="termination-ok-btn">${this.terminatedConfirmValue}</button>
        </div>
      </div>
      <div class="modal-backdrop bg-black/50"></div>
    `
    document.body.appendChild(dialog)

    document.getElementById("termination-ok-btn").addEventListener("click", () => {
      window.location.href = "/"
    })
  }
}
