# frozen_string_literal: true

module NasaGame
  class IndividualRankingsController < BaseController
    include ParticipantAuthentication

    before_action :authenticate_participant!
    before_action :set_participant
    before_action :ensure_individual_phase
    before_action :ensure_not_completed

    # POST /nasa_game/participants/:participant_id/individual_rankings
    # Batch update rankings from sortable list
    def create
      update_rankings
    end

    # PATCH /nasa_game/participants/:participant_id/individual_rankings/:id
    def update
      update_rankings
    end

    private

    def set_participant
      @participant = current_participant

      # Ensure accessing own rankings
      if params[:participant_id].present? && @participant.id.to_s != params[:participant_id]
        head :forbidden
      end
    end

    def ensure_individual_phase
      unless @participant.session.individual?
        head :forbidden
      end
    end

    def ensure_not_completed
      if @participant.individual_completed?
        head :forbidden
      end
    end

    def update_rankings
      rankings_data = params[:rankings]

      return head :bad_request unless rankings_data.is_a?(Array)

      ActiveRecord::Base.transaction do
        rankings_data.each_with_index do |item_id, index|
          ranking = @participant.individual_rankings.find_by(item_id: item_id)
          ranking&.update!(rank: index + 1)
        end
      end

      head :ok
    rescue ActiveRecord::RecordInvalid
      head :unprocessable_entity
    end
  end
end
