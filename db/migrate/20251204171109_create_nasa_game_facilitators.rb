# frozen_string_literal: true

class CreateNasaGameFacilitators < ActiveRecord::Migration[8.0]
  def change
    create_table :nasa_game_facilitators, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :session, null: false, foreign_key: { to_table: :nasa_game_sessions }, type: :uuid
      t.timestamps
    end

    add_index :nasa_game_facilitators, %i[user_id session_id], unique: true
  end
end
