class CreateNasaGameGroupRankings < ActiveRecord::Migration[8.0]
  def change
    create_table :nasa_game_group_rankings, id: :uuid do |t|
      t.references :group, null: false, foreign_key: { to_table: :nasa_game_groups }, type: :uuid
      t.integer :item_id, null: false
      t.integer :rank, null: false
      t.timestamps
    end

    add_index :nasa_game_group_rankings, %i[group_id item_id], unique: true
  end
end
