# frozen_string_literal: true

# Ticket 12: build the ActiveAdmin v4 Tailwind bundle with the nodeless
# standalone CLI shipped by tailwindcss-ruby (no node/yarn). The default
# `tailwindcss:build` task only compiles the app's own stylesheet, so the
# admin bundle gets its own input, config, and output. Output lands in
# app/assets/builds so Propshaft serves it as /assets/active_admin-<digest>.css.
require "tailwindcss/ruby"

namespace :active_admin do
  input  = "app/assets/stylesheets/active_admin.css"
  output = "app/assets/builds/active_admin.css"
  config = "tailwind-active_admin.config.js"

  def aa_tailwind(*args)
    command = [ Tailwindcss::Ruby.executable.to_s, *args ]
    system(*command, exception: true)
  end

  desc "Build the ActiveAdmin Tailwind stylesheet"
  task build: :environment do
    aa_tailwind("-i", input, "-o", output, "-c", config, "--minify")
  end

  desc "Watch and rebuild the ActiveAdmin Tailwind stylesheet on change"
  task watch: :environment do
    aa_tailwind("-i", input, "-o", output, "-c", config, "-w")
  end
end

# Compile the admin bundle alongside the rest of the assets on deploy.
if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance([ "active_admin:build" ])
end
