# frozen_string_literal: true

module AdminResources
  # Ticket 12: shared Active Admin behaviour for soft-deletable resources.
  #
  # `install(self)` from inside an `ActiveAdmin.register` block adds:
  #   * the Kept / Discarded / All index scopes (Kept is the default view),
  #   * a "Discard" member action and its inverse "Restore", and
  #   * removal of the destroy action — records are only ever soft-deleted.
  #
  # Discarding stamps `discarded_by` with the acting admin: the Discardable
  # model concern reads Current.user in its before_discard hook, so we set it
  # for the duration of the call.
  module Discardable
    def self.install(dsl)
      dsl.instance_exec do
        actions :all, except: [ :destroy ]

        scope :kept, default: true
        scope :discarded
        scope :all

        member_action :discard, method: :put do
          Current.set(user: current_admin) { resource.discard }
          redirect_back_or_to(collection_path, notice: "#{resource.class.model_name.human} discarded.")
        end

        member_action :undiscard, method: :put do
          resource.undiscard
          redirect_back_or_to(collection_path, notice: "#{resource.class.model_name.human} restored.")
        end

        action_item :discard, only: :show, if: proc { resource.kept? } do
          link_to "Discard", {action: :discard, id: resource.id}, method: :put,
            data: {confirm: "Discard this #{resource.class.model_name.human.downcase}?"}
        end

        action_item :undiscard, only: :show, if: proc { resource.discarded? } do
          link_to "Restore", {action: :undiscard, id: resource.id}, method: :put
        end
      end
    end
  end
end
