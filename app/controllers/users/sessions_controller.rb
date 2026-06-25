# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    redirect_to "/login", allow_other_host: false
  end
end
