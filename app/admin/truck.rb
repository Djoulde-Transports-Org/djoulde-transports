# frozen_string_literal: true

ActiveAdmin.register Truck do
  menu parent: "Fleet", priority: 1

  AdminResources::Discardable.install(self)

  permit_params :plate_number, :vin, :make, :model, :year, :status

  filter :plate_number
  filter :make
  filter :model
  filter :status, as: :select, collection: Truck.statuses.keys
  filter :created_at

  index do
    selectable_column
    id_column
    column :plate_number
    column :make
    column :model
    column :year
    column :status
    column("Tank") { |truck| link_to(truck.tank.id, admin_tank_path(truck.tank)) if truck.tank }
    column :discarded_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :plate_number
      row :vin
      row :make
      row :model
      row :year
      row :status
      row("Created by") { |truck| truck.created_by&.email }
      row :created_at
      row :updated_at
      row :discarded_at
      row("Discarded by") { |truck| truck.discarded_by&.email }
    end

    panel "Tank" do
      if resource.tank
        attributes_table_for resource.tank do
          row(:plate_number) { |tank| link_to tank.plate_number, admin_tank_path(tank) }
          row :capacity
          row :status
          row :vin
        end
      else
        span "No tank assigned to this truck."
      end
    end

    active_admin_comments_for(resource)
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :plate_number
      f.input :vin
      f.input :make
      f.input :model
      f.input :year
      f.input :status, as: :select, collection: Truck.statuses.keys
    end
    f.actions
  end

  controller do
    def build_resource
      super.tap { |truck| truck.created_by ||= current_admin }
    end
  end
end
