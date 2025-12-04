# frozen_string_literal: true

module NasaGame
  class ParticipantsController < BaseController
    include ParticipantAuthentication

    before_action :set_group, only: %i[new create]
    before_action :authenticate_participant!, only: %i[show update]
    before_action :set_participant, only: %i[show update]

    def new
      # Redirect if already joined this session
      existing_participant = current_user.nasa_game_participants.find_by(session: @group.session)
      if existing_participant
        redirect_to nasa_game_participant_path(existing_participant)
        return
      end

      @participant = Participant.new
    end

    def create
      @participant = @group.participants.build(participant_params)
      @participant.session = @group.session
      @participant.user = current_user

      if @participant.save
        redirect_to nasa_game_participant_path(@participant), notice: "グループに参加しました"
      else
        flash.now[:alert] = "参加に失敗しました"
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @session = @participant.session
      @group = @participant.group

      # Render phase-specific template
      case @session.phase
      when "lobby"
        render :lobby
      when "individual"
        prepare_individual_work
        render :individual_work
      when "team"
        prepare_team_work
        render :team_work
      when "result"
        prepare_result
        render :result
      end
    end

    def update
      @session = @participant.session
      @group = @participant.group

      # Only allow completing individual work during individual phase
      unless @session.individual?
        redirect_to nasa_game_participant_path(@participant), alert: "現在のフェーズでは操作できません"
        return
      end

      if @participant.individual_completed?
        redirect_to nasa_game_participant_path(@participant), alert: "既に個人ワークを完了しています"
        return
      end

      @participant.update!(individual_completed_at: Time.current)
      redirect_to nasa_game_participant_path(@participant), notice: "個人ワークを完了しました"
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def set_participant
      @participant = current_participant

      # Ensure the participant is accessing their own page
      if params[:id].present? && @participant.id.to_s != params[:id]
        redirect_to nasa_game_participant_path(@participant)
      end
    end

    def participant_params
      params.require(:nasa_game_participant).permit(:display_name)
    end

    def prepare_individual_work
      # Initialize rankings if not exist
      if @participant.individual_rankings.empty?
        Item.all.each_with_index do |item, index|
          @participant.individual_rankings.create!(
            item_id: item.id,
            rank: index + 1
          )
        end
      end

      @rankings = @participant.individual_rankings.order(:rank)
    end

    def prepare_team_work
      # Initialize group rankings if not exist
      if @group.group_rankings.empty?
        Item.all.each_with_index do |item, index|
          @group.group_rankings.create!(
            item_id: item.id,
            rank: index + 1
          )
        end
      end

      @group_rankings = @group.group_rankings.order(:rank)
      @individual_rankings = @participant.individual_rankings.order(:rank)
    end

    def prepare_result
      @group_rankings = @group.group_rankings.order(:rank)
      @individual_rankings = @participant.individual_rankings.order(:rank)

      # Calculate scores
      @individual_score = calculate_score(@individual_rankings)
      @team_score = calculate_score(@group_rankings)

      # Calculate average individual score for synergy
      individual_scores = @group.participants.map do |p|
        calculate_score(p.individual_rankings)
      end
      @average_individual_score = individual_scores.sum.to_f / individual_scores.size
      @synergy_effect = (@average_individual_score - @team_score).round(1)
    end

    def calculate_score(rankings)
      rankings.sum do |ranking|
        item = Item.find(ranking.item_id)
        (ranking.rank - item.correct_rank).abs
      end
    end
  end
end
