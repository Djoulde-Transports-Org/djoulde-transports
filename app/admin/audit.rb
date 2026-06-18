# frozen_string_literal: true

# Ticket 12: read-only window onto the `audited` trail. No create/edit/destroy —
# audits are written by the gem as a side effect of model changes.
#
# The audit model normally loads through audited's `on_load(:active_record)`
# hook. Active Admin resources can be loaded before that fires (eager load,
# `rails routes`), so require it here to resolve the constant below. In a booted
# server the hook has already run, making this a no-op.
require "audited/audit"

ActiveAdmin.register Audited::Audit, as: "Audit" do
  menu parent: "Access", priority: 3, label: "Audits"

  actions :index, :show

  config.sort_order = "created_at_desc"

  filter :auditable_type, as: :select,
    collection: -> { Audited::Audit.distinct.order(:auditable_type).pluck(:auditable_type).compact }
  filter :action, as: :select, collection: %w(create update destroy)
  filter :user_id
  filter :created_at

  index do
    id_column
    column :auditable_type
    column :auditable_id
    column :action
    column("User") { |audit| audit.user&.email || audit.username }
    column :version
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :auditable_type
      row :auditable_id
      row :action
      row :version
      row("User") { |audit| audit.user&.email || audit.username }
      row :remote_address
      row :request_uuid
      row :comment
      row :created_at
      row("Changes") { |audit| pre JSON.pretty_generate(audit.audited_changes) }
    end
  end
end
