# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_04_140641) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "nasa_game_group_rankings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "group_id", null: false
    t.integer "item_id", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "item_id"], name: "index_nasa_game_group_rankings_on_group_id_and_item_id", unique: true
    t.index ["group_id"], name: "index_nasa_game_group_rankings_on_group_id"
  end

  create_table "nasa_game_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "session_id", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_nasa_game_groups_on_session_id"
  end

  create_table "nasa_game_individual_rankings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "participant_id", null: false
    t.integer "item_id", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "item_id"], name: "idx_on_participant_id_item_id_022705fc06", unique: true
    t.index ["participant_id"], name: "index_nasa_game_individual_rankings_on_participant_id"
  end

  create_table "nasa_game_participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "session_id", null: false
    t.uuid "group_id", null: false
    t.string "session_token", null: false
    t.string "display_name", null: false
    t.datetime "individual_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_nasa_game_participants_on_group_id"
    t.index ["session_id"], name: "index_nasa_game_participants_on_session_id"
    t.index ["session_token"], name: "index_nasa_game_participants_on_session_token", unique: true
  end

  create_table "nasa_game_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "phase", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "nasa_game_group_rankings", "nasa_game_groups", column: "group_id"
  add_foreign_key "nasa_game_groups", "nasa_game_sessions", column: "session_id"
  add_foreign_key "nasa_game_individual_rankings", "nasa_game_participants", column: "participant_id"
  add_foreign_key "nasa_game_participants", "nasa_game_groups", column: "group_id"
  add_foreign_key "nasa_game_participants", "nasa_game_sessions", column: "session_id"
end
