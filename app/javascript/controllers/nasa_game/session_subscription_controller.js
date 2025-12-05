import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to NasaGame::SessionChannel for phase changes and dashboard updates
export default class extends Controller {
  static values = {
    sessionId: String,
    currentPhase: String,
    isFacilitator: { type: Boolean, default: false }
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
}
