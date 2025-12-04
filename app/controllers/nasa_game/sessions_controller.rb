# frozen_string_literal: true

module NasaGame
  class SessionsController < BaseController
    before_action :set_session, only: %i[show update]

    def new
      @session = Session.new
    end

    def create
      group_count = params[:group_count].to_i.clamp(1, 20)

      @session = Session.new(phase: :lobby)

      ActiveRecord::Base.transaction do
        @session.save!
        group_count.times do |i|
          @session.groups.create!(
            name: "グループ #{i + 1}",
            position: i
          )
        end
      end

      redirect_to nasa_game_session_path(@session), notice: "セッションを作成しました"
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "セッションの作成に失敗しました: #{e.message}"
      render :new, status: :unprocessable_entity
    end

    def show
      @groups = @session.groups.includes(:participants).order(:position)
    end

    def update
      case session_params[:phase]
      when "individual"
        return unless @session.lobby?

        @session.individual!
      when "team"
        return unless @session.individual?

        @session.team!
      when "result"
        return unless @session.team?

        @session.result!
      else
        redirect_to nasa_game_session_path(@session), alert: "無効なフェーズです"
        return
      end

      redirect_to nasa_game_session_path(@session), notice: "フェーズを更新しました"
    end

    private

    def set_session
      @session = Session.find(params[:id])
    end

    def session_params
      params.require(:session).permit(:phase)
    end
  end
end
