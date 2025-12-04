# frozen_string_literal: true

module UserAuthentication
  extend ActiveSupport::Concern

  COOKIE_KEY = :tsumugy_session_token

  included do
    helper_method :current_user
  end

  private

  def current_user
    @current_user ||= find_or_create_user_from_cookie
  end

  def find_or_create_user_from_cookie
    token = cookies.signed[COOKIE_KEY]
    user = find_active_user(token) if token
    user || create_and_store_user
  end

  def find_active_user(token)
    user = User.find_by(session_token: token)
    return nil unless user
    return nil if user.expired?

    # Extend expiration on each access
    user.extend_expiration!
    store_user_token(user)
    user
  end

  def create_and_store_user
    user = User.create!
    store_user_token(user)
    user
  end

  def store_user_token(user)
    cookies.signed[COOKIE_KEY] = {
      value: user.session_token,
      expires: user.expires_at,
      httponly: true
    }
  end

  def clear_user_token
    cookies.delete(COOKIE_KEY)
  end
end
