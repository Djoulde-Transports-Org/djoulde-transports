# frozen_string_literal: true

# The maintenance "kind" used to be a fixed enum. Users now need to add new
# kinds on the fly from the create-maintenance drawer, so it becomes a real
# lookup table instead. The four existing enum values are seeded as rows so
# their integer positions map 1:1 to the new foreign key.
class ReplaceMaintenanceKindEnumWithReferenceTable < ActiveRecord::Migration[8.1]
  KIND_NAMES = %w[routine repair inspection oil_change].freeze

  def up
    create_table :maintenance_kinds do |t|
      t.string :name, null: false

      t.datetime :discarded_at
      t.bigint   :discarded_by_id

      t.timestamps
    end

    add_index :maintenance_kinds, :name, unique: true
    add_index :maintenance_kinds, :discarded_at
    add_index :maintenance_kinds, :discarded_by_id

    add_foreign_key :maintenance_kinds, :users, column: :discarded_by_id

    now = quote(Time.current.strftime("%Y-%m-%d %H:%M:%S"))
    KIND_NAMES.each do |name|
      execute "INSERT INTO maintenance_kinds (name, created_at, updated_at) VALUES (#{quote(name)}, #{now}, #{now})"
    end

    add_reference :maintenances, :maintenance_kind, foreign_key: true

    KIND_NAMES.each_with_index do |name, index|
      kind_id = select_value("SELECT id FROM maintenance_kinds WHERE name = #{quote(name)}")
      execute "UPDATE maintenances SET maintenance_kind_id = #{kind_id} WHERE kind = #{index}"
    end

    change_column_null :maintenances, :maintenance_kind_id, false

    remove_column :maintenances, :kind
  end

  def down
    add_column :maintenances, :kind, :integer, default: 0, null: false

    KIND_NAMES.each_with_index do |name, index|
      kind_id = select_value("SELECT id FROM maintenance_kinds WHERE name = #{quote(name)}")
      execute "UPDATE maintenances SET kind = #{index} WHERE maintenance_kind_id = #{kind_id}"
    end

    remove_reference :maintenances, :maintenance_kind, foreign_key: true

    drop_table :maintenance_kinds
  end
end
