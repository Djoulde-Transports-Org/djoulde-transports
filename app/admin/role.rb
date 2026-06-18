# frozen_string_literal: true

# Roles are seeded (super_admin, dispatcher, billing, maintenance,
# driver_readonly) and assigned to Users. They are not soft-deletable, so this
# resource keeps the standard actions minus destroy.
ActiveAdmin.register Role do
  menu parent: "Access", priority: 2

  actions :all, except: [ :destroy ]

  permit_params :name

  filter :name
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column("Users") { |role| role.users.count }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :resource_type
      row :created_at
    end
    panel "Users" do
      table_for role.users.order(:email) do
        column(:email) { |user| link_to user.email, admin_user_path(user) }
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
    end
    f.actions
  end
end
