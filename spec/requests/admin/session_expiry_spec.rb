# frozen_string_literal: true

# Ticket 12: admin session expiry. Sessions go stale after an hour of inactivity
# (Devise :timeoutable) and are invalidated whenever the app restarts/redeploys
# (per-boot token stamped on the session and checked in authenticate_admin!).
RSpec.describe "Admin session expiry", type: :request do
  describe "configuration" do
    it "enables timeoutable on the User model" do
      expect(User.devise_modules).to include(:timeoutable)
    end

    it "expires idle sessions after one hour" do
      expect(Devise.timeout_in).to eq(1.hour)
    end
  end

  describe "session boot token" do
    let(:admin) { create_admin }
    let(:html) { {"Accept" => "text/html"} }

    it "lets a session created in the current boot reach the admin area" do
      sign_in admin

      get "/admin/routes", headers: html

      expect(response).to have_http_status(:ok)
    end

    it "forces re-login when the session predates the current boot", :aggregate_failures do
      sign_in admin

      # First request stamps the current boot token onto the session; from here
      # the cookie carries it and later requests just fetch it back.
      get "/admin/routes", headers: html
      expect(response).to have_http_status(:ok)

      # Simulate a restart/redeploy: the running process now holds a different
      # boot token than the one stamped on the existing session.
      allow(Rails.application.config.x).to receive(:session_boot_token).and_return("a-newer-boot")

      get "/admin/routes", headers: html

      expect(response).to redirect_to("/login")
      expect(flash[:alert]).to match(/sign in again/i)
    end
  end

  describe "sign in" do
    it "redirects to the admin area" do
      admin = create_admin

      post user_session_path,
        params: {user: {email: admin.email, password: AdminAuth::PASSWORD}},
        headers: {"Accept" => "text/html"}

      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "sign out" do
    it "redirects to the login page" do
      sign_in create_admin

      delete destroy_user_session_path, headers: {"Accept" => "text/html"}

      expect(response).to redirect_to("/login")
    end
  end

  describe "token_expires_at expiry" do
    let(:admin) { create_admin }
    let(:html)  { {"Accept" => "text/html"} }
    let(:oauth_app) do
      OauthApplication.create!(
        name:         "spa",
        redirect_uri: "https://example.com/cb",
        owner:        admin
      )
    end

    context "when the API login stores a future token_expires_at" do
      before do
        oauth_app
        post "/api/v1/sessions",
          params: {email: admin.email, password: AdminAuth::PASSWORD},
          as:     :json
      end

      it "stores token_expires_at as a future unix timestamp" do
        expect(session[:token_expires_at]).to be_a(Integer).and be > Time.current.to_i
      end

      it "allows access to the admin area while the token is valid" do
        get "/admin/routes", headers: html
        expect(response).to have_http_status(:ok)
      end
    end

    context "when token_expires_at has passed" do
      before do
        oauth_app
        post "/api/v1/sessions",
          params: {email: admin.email, password: AdminAuth::PASSWORD},
          as:     :json
        # token_expires_at = now + 7200. Advance Time.current past that.
        # Devise timeoutable also calls Time.current via timeout_in.ago, so
        # extend timeout_in to 24h first to prevent timeoutable from firing
        # before authenticate_admin! can check the Doorkeeper token expiry.
        allow(Devise).to receive(:timeout_in).and_return(24.hours)
        allow(Time).to receive(:current).and_return(4.hours.from_now)
        get "/admin/routes", headers: html
      end

      it "redirects to login" do
        expect(response).to redirect_to("/login")
      end

      it "shows a session expired alert" do
        expect(flash[:alert]).to match(/sign in again/i)
      end
    end

    context "when token_expires_at is absent (direct Devise sign-in)" do
      before do
        sign_in admin
        get "/admin/routes", headers: html
      end

      it "allows access without a token expiry timestamp" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
