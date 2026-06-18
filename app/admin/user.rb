# frozen_string_literal: true

ActiveAdmin.register User do
  menu parent: "Access", priority: 1

  AdminResources::Discardable.install(self)

  # role_ids drives the Rolify has_and_belongs_to_many assignment.
  permit_params :email, :password, :password_confirmation, role_ids: []

  filter :email
  filter :roles, as: :select, collection: -> { Role.order(:name).pluck(:name, :id) }
  filter :confirmed_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :email
    column("Roles") { |user| user.roles.map(&:name).join(", ") }
    column :confirmed_at
    column :sign_in_count
    column :last_sign_in_at
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row("Roles") { |user| user.roles.map(&:name).join(", ") }
      row :confirmed_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :locked_at
      row :created_at
      row :discarded_at
      row("Discarded by") { |user| user.discarded_by&.email }
    end
    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs "Account" do
      f.input :email
      f.input :password,
        hint: (f.object.persisted? ? "Leave blank to keep the current password" : nil)
      f.input :password_confirmation
    end
    f.inputs "Roles" do
      f.input :role_ids, as: :check_boxes,
        collection: Role.order(:name).map { |role| [ role.name, role.id ] }
    end
    f.actions
  end

  controller do
    # Devise rejects a blank password on update, so drop the password params
    # entirely when the admin left them empty (i.e. is only editing roles).
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      super
    end
  end
end
