# frozen_string_literal: true

module SystemHelpers
  # Accept custom confirm dialog (DaisyUI modal)
  # Usage: accept_custom_confirm { click_button "Submit" }
  def accept_custom_confirm
    yield if block_given?

    # Wait for the modal to appear and click confirm button
    within(".modal[open]", wait: 5) do
      click_button(class: "btn-primary") rescue click_button(class: "btn-error")
    end
  end

  # Cancel custom confirm dialog (DaisyUI modal)
  # Usage: cancel_custom_confirm { click_button "Submit" }
  def cancel_custom_confirm
    yield if block_given?

    # Wait for the modal to appear and click cancel button
    within(".modal[open]", wait: 5) do
      find("button[data-action='confirm-dialog#cancel']").click
    end
  end

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
