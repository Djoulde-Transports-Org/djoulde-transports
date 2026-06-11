# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class List < Grape::API
    resource :routes do
      desc "List routes (kept only)."
      paginate per_page: 25, max_per_page: 100
      get do
        authorize!(::Route, :index)
        present paginate(policy_scope(::Route).order(:origin, :destination)), with: ::API::V1::Entities::Route
      end
    end
  end
end
