# frozen_string_literal: true

module NasaGame
  class GroupsController < BaseController
    include ParticipantAuthentication

    before_action :set_group

    def show
      # Redirect to join page if not authenticated or not in this group
      if current_participant.nil? || current_participant.group_id != @group.id
        redirect_to new_nasa_game_group_participant_path(@group)
        return
      end

      # Redirect to participant's page (which handles phase routing)
      redirect_to nasa_game_participant_path(current_participant)
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end
  end
end
