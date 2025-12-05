# frozen_string_literal: true

module NasaGame
  class GroupRankingsController < BaseController
    include ParticipantAuthentication

    before_action :set_group
    before_action :authenticate_participant!
    before_action :ensure_participant_belongs_to_group
    before_action :ensure_team_phase
    before_action :ensure_not_completed

    # POST /nasa_game/groups/:group_id/group_rankings
    # Batch update group rankings from sortable list
    def create
      update_rankings
    end

    # PATCH /nasa_game/groups/:group_id/group_rankings/:id
    def update
      update_rankings
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def ensure_participant_belongs_to_group
      unless current_participant&.group_id == @group.id
        head :forbidden
      end
    end

    def ensure_team_phase
      unless @group.session.team?
        head :forbidden
      end
    end

    def ensure_not_completed
      if @group.completed?
        head :forbidden
      end
    end

    def update_rankings
      rankings_data = params[:rankings]

      return head :bad_request unless rankings_data.is_a?(Array)

      ActiveRecord::Base.transaction do
        rankings_data.each_with_index do |item_id, index|
          ranking = @group.group_rankings.find_by(item_id: item_id)
          ranking&.update!(rank: index + 1)
        end
      end

      head :ok
    rescue ActiveRecord::RecordInvalid
      head :unprocessable_entity
    end
  end
end
