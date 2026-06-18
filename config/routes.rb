# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # API login is custom-Grape (token-based); registration is admin-only via
  # Active Admin (ticket 12). Devise sessions stay enabled for the cookie-based
  # /admin browser login. Confirmations/passwords/unlocks are driven by email
  # links.
  devise_for :users, skip: [ :registrations ]

  use_doorkeeper

  mount API::Root => "/"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
