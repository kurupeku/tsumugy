class CreateNasaGameSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :nasa_game_sessions, id: :uuid do |t|
      t.integer :phase, default: 0, null: false

      t.timestamps
    end
  end
end
