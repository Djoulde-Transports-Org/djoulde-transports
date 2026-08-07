# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class List < Grape::API
    helpers do
      def route_scope
        policy_scope(::Route)
          .then { |s| params[:origin].present? ? s.where(origin: params[:origin]) : s }
          .order(:origin, :destination)
      end
    end

    resource :routes do
      desc "List routes (kept only)."
      paginate per_page: 25, max_per_page: 100
      params do
        optional :origin, type: String, documentation: {desc: "Filter to routes with this exact origin."}
      end
      get do
        authorize!(::Route, :index)
        present paginate(route_scope), with: ::API::V1::Entities::Route
      end
    end
  end
end
