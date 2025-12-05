# frozen_string_literal: true

module NasaGame
  class BaseController < ApplicationController
    layout "nasa_game"

    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    private

    def handle_not_found
      redirect_to root_path, alert: I18n.t("nasa_game.errors.not_found")
    end
  end
end
