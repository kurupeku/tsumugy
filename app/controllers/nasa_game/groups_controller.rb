# frozen_string_literal: true

module NasaGame
  class GroupsController < BaseController
    include ParticipantAuthentication

    before_action :set_group
    before_action :authenticate_participant!, only: [ :update ]
    before_action :ensure_team_phase, only: [ :update ]
    before_action :ensure_not_completed, only: [ :update ]
    before_action :ensure_belongs_to_group, only: [ :update ]

    def show
      # Redirect to join page if not authenticated or not in this group
      if current_participant.nil? || current_participant.group_id != @group.id
        redirect_to new_nasa_game_group_participant_path(@group)
        return
      end

      # Redirect to participant's page (which handles phase routing)
      redirect_to nasa_game_participant_path(current_participant)
    end

    def update
      @group.update!(completed_at: Time.current)
      redirect_to nasa_game_participant_path(current_participant), notice: t(".flash.team_completed")
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end

    def ensure_team_phase
      return if @group.session.team?

      redirect_to nasa_game_participant_path(current_participant), alert: t("nasa_game.participants.flash.invalid_phase")
    end

    def ensure_not_completed
      return unless @group.completed?

      redirect_to nasa_game_participant_path(current_participant), alert: t(".flash.already_completed")
    end

    def ensure_belongs_to_group
      return if current_participant.group_id == @group.id

      head :forbidden
    end
  end
end
