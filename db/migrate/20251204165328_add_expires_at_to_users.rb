# frozen_string_literal: true

class AddExpiresAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :expires_at, :datetime, null: false, default: -> { "NOW() + INTERVAL '1 day'" }
    add_index :users, :expires_at
  end
end
