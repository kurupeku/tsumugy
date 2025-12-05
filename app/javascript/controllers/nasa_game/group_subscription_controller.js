import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to NasaGame::GroupChannel for team ranking sync
export default class extends Controller {
  static values = {
    groupId: String,
    participantId: String
  }

  connect() {
    console.log("[GroupSubscription] Connecting to group:", this.groupIdValue)

    this.channel = createConsumer().subscriptions.create(
      {
        channel: "NasaGame::GroupChannel",
        group_id: this.groupIdValue
      },
      {
        connected: () => {
          console.log("[GroupSubscription] Connected successfully")
        },
        disconnected: () => {
          console.log("[GroupSubscription] Disconnected")
        },
        rejected: () => {
          console.log("[GroupSubscription] Connection rejected")
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
    console.log("[GroupSubscription] Received message:", data)

    switch (data.type) {
      case "ranking_changed":
        this.handleRankingChange(data)
        break
      case "team_completed":
        this.handleTeamCompleted()
        break
    }
  }

  handleRankingChange(data) {
    // Ignore own changes to prevent flicker
    if (data.changed_by === this.participantIdValue) return

    // Update the ranking list
    const rankingList = document.getElementById("team-ranking-list")
    if (rankingList && data.html) {
      rankingList.outerHTML = data.html
    }
  }

  handleTeamCompleted() {
    // Reload page to show completed state
    window.location.reload()
  }
}
