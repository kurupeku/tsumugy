# frozen_string_literal: true

class AddExpiresAtToNasaGameSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :nasa_game_sessions, :expires_at, :datetime, null: false, default: -> { "(now() + 'P1D'::interval)" }
    add_index :nasa_game_sessions, :expires_at
  end
end
