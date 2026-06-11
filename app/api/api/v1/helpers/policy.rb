# frozen_string_literal: true

module API::V1::Helpers
  # Bridges Pundit into Grape endpoints. `authenticate!` (see Auth) sets
  # `Current.user`, so `pundit_user` always reflects the bearer token's owner.
  module Policy
    extend Grape::API::Helpers

    def pundit_user
      current_user
    end

    def authorize!(record, action)
      Pundit.authorize(pundit_user, record, "#{action}?".to_sym)
    end

    def policy_scope(scope)
      Pundit.policy_scope!(pundit_user, scope)
    end

    def find_kept!(klass, id_param: :id)
      record = policy_scope(klass).kept.find_by(id: params[id_param])
      not_found!(message: "#{klass.model_name.human} not found.") if record.nil?
      record
    end
  end
end
