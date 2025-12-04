class CreateNasaGameGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :nasa_game_groups, id: :uuid do |t|
      t.references :session, null: false, foreign_key: { to_table: :nasa_game_sessions }, type: :uuid
      t.string :name, null: false
      t.integer :position, null: false
      t.datetime :completed_at

      t.timestamps
    end
  end
end
