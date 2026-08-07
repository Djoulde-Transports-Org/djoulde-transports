# frozen_string_literal: true

module API::V1::Endpoints::Routes
  class Origins < Grape::API
    resource :routes do
      desc "List distinct route origins (kept only)."
      get "/origins" do
        authorize!(::Route, :index)
        policy_scope(::Route).distinct.order(:origin).pluck(:origin)
      end
    end
  end
end
