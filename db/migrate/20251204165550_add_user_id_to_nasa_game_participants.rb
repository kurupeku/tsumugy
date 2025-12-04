# frozen_string_literal: true

class AddUserIdToNasaGameParticipants < ActiveRecord::Migration[8.0]
  def up
    # 1. Add user_id column (nullable initially)
    add_reference :nasa_game_participants, :user, type: :uuid, null: true, foreign_key: true

    # 2. Migrate existing data: create User from session_token
    execute <<-SQL.squish
      INSERT INTO users (id, session_token, expires_at, created_at, updated_at)
      SELECT gen_random_uuid(), session_token, NOW() + INTERVAL '1 day', created_at, updated_at
      FROM nasa_game_participants
      WHERE session_token IS NOT NULL
      ON CONFLICT (session_token) DO NOTHING
    SQL

    # 3. Link existing Participants to Users
    execute <<-SQL.squish
      UPDATE nasa_game_participants
      SET user_id = users.id
      FROM users
      WHERE nasa_game_participants.session_token = users.session_token
    SQL

    # 4. Make user_id NOT NULL
    change_column_null :nasa_game_participants, :user_id, false

    # 5. Add unique index [user_id, session_id]
    add_index :nasa_game_participants, %i[user_id session_id], unique: true

    # 6. Remove session_token column and its index
    remove_index :nasa_game_participants, :session_token
    remove_column :nasa_game_participants, :session_token
  end

  def down
    # Restore session_token column
    add_column :nasa_game_participants, :session_token, :string

    # Copy session_token from User back to Participant
    execute <<-SQL.squish
      UPDATE nasa_game_participants
      SET session_token = users.session_token
      FROM users
      WHERE nasa_game_participants.user_id = users.id
    SQL

    change_column_null :nasa_game_participants, :session_token, false
    add_index :nasa_game_participants, :session_token, unique: true

    # Remove unique index [user_id, session_id]
    remove_index :nasa_game_participants, %i[user_id session_id]

    # Remove user_id column
    remove_reference :nasa_game_participants, :user
  end
end
