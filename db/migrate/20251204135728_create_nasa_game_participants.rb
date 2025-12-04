class CreateNasaGameParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :nasa_game_participants, id: :uuid do |t|
      t.references :session, null: false, foreign_key: { to_table: :nasa_game_sessions }, type: :uuid
      t.references :group, null: false, foreign_key: { to_table: :nasa_game_groups }, type: :uuid
      t.string :session_token, null: false
      t.string :display_name, null: false
      t.datetime :individual_completed_at

      t.timestamps
    end

    add_index :nasa_game_participants, :session_token, unique: true
  end
end
