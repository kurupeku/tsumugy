# frozen_string_literal: true

module LocaleDetection
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
  end

  private

  def switch_locale(&action)
    locale = extract_locale_from_accept_language_header
    I18n.with_locale(locale, &action)
  end

  def extract_locale_from_accept_language_header
    accept_language = request.env["HTTP_ACCEPT_LANGUAGE"]
    return I18n.default_locale unless accept_language

    # Extract the primary language from Accept-Language header
    preferred_language = accept_language.scan(/\A[a-z]{2}/).first&.to_sym

    # Return :ja for Japanese, :en for all others
    preferred_language == :ja ? :ja : :en
  end
end
