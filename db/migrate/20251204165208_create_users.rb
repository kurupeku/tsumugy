# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :session_token, null: false

      t.timestamps
    end

    add_index :users, :session_token, unique: true
  end
end
