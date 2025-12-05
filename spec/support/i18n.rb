# frozen_string_literal: true

# Force Japanese locale for System Specs
# This ensures all system tests run with consistent Japanese text,
# allowing assertions to be written in Japanese without locale concerns.

RSpec.configure do |config|
  config.before(:each, type: :system) do
    I18n.locale = :ja
  end

  config.after(:each, type: :system) do
    I18n.locale = I18n.default_locale
  end
end
