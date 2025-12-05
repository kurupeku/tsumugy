# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = cookies.signed[:tsumugy_session_token]
      return nil unless token

      user = User.find_by(session_token: token)
      return nil unless user
      return reject_unauthorized_connection if user.expired?

      user
    end
  end
end
