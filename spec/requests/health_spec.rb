# frozen_string_literal: true

RSpec.describe "Health", type: :request do
  describe "GET /up" do
    it "returns 200 OK" do
      get "/up"
      expect(response).to have_http_status(:ok)
    end
  end
end
