# frozen_string_literal: true

module SystemHelpers
  # Dismiss any visible toast notifications by clicking their close buttons
  # or wait for them to disappear automatically
  def dismiss_toasts
    # Wait until all toasts are gone (either by clicking or auto-dismiss)
    Timeout.timeout(6) do
      loop do
        toast_button = page.first(".toast .alert button[data-action='toast#dismiss']", minimum: 0, wait: false)
        break unless toast_button

        begin
          toast_button.click
        rescue Playwright::Error
          # Element may have been removed during auto-dismiss, continue
        end
        sleep 0.1
      end
    end
  rescue Timeout::Error
    # If toasts don't disappear within timeout, continue anyway
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
