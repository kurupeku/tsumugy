class CreateNasaGameIndividualRankings < ActiveRecord::Migration[8.0]
  def change
    create_table :nasa_game_individual_rankings, id: :uuid do |t|
      t.references :participant, null: false, foreign_key: { to_table: :nasa_game_participants }, type: :uuid
      t.integer :item_id, null: false
      t.integer :rank, null: false

      t.timestamps
    end

    add_index :nasa_game_individual_rankings, %i[participant_id item_id], unique: true
  end
end
