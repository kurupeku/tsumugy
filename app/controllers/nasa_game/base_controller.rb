# frozen_string_literal: true

module NasaGame
  class BaseController < ApplicationController
    layout "nasa_game"

    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    private

    def handle_not_found
      redirect_to nasa_game_root_path, alert: "指定されたページが見つかりませんでした"
    end
  end
end
