# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers", preload: true
pin_all_from "app/javascript/controllers/nasa_game", under: "controllers/nasa_game", preload: true

# Action Cable
pin "@rails/actioncable", to: "actioncable.esm.js"

# Third-party libraries
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/+esm"
