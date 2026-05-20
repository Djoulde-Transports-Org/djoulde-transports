class InstallAudited < ActiveRecord::Migration[8.1]
  def self.up
    create_table :audits, force: true do |t|
      t.references :auditable,  polymorphic: true
      t.references :associated, polymorphic: true
      t.references :user,       polymorphic: true
      t.string :username
      t.string :action
      t.text :audited_changes, limit: 16_777_215
      t.integer :version, default: 0
      t.string :comment
      t.string :remote_address
      t.string :request_uuid
      t.datetime :created_at
    end

    add_index :audits, [ :auditable_type, :auditable_id, :version ], name: "auditable_index"
    add_index :audits, [ :associated_type, :associated_id ], name: "associated_index"
    add_index :audits, [ :user_id, :user_type ], name: "user_index"
    add_index :audits, :request_uuid
    add_index :audits, :created_at
  end

  def self.down
    drop_table :audits
  end
end
