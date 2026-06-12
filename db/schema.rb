# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_12_120100) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action"
    t.bigint "associated_id"
    t.string "associated_type"
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes", size: :medium
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.bigint "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["associated_type", "associated_id"], name: "index_audits_on_associated"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["auditable_type", "auditable_id"], name: "index_audits_on_auditable"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
    t.index ["user_type", "user_id"], name: "index_audits_on_user"
  end

  create_table "billing_line_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amount", null: false
    t.bigint "billing_statement_id", null: false
    t.datetime "created_at", null: false
    t.string "delivery_note_number"
    t.string "destination"
    t.integer "diesel_quantity", default: 0, null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.integer "gasoline_quantity", default: 0, null: false
    t.string "origin"
    t.decimal "rate", precision: 12, scale: 2, default: "0.0", null: false
    t.date "started_on"
    t.bigint "trip_id", null: false
    t.integer "tva", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["billing_statement_id", "trip_id"], name: "index_billing_line_items_on_statement_and_trip", unique: true
    t.index ["billing_statement_id"], name: "index_billing_line_items_on_billing_statement_id"
    t.index ["delivery_note_number"], name: "index_billing_line_items_on_delivery_note_number"
    t.index ["discarded_at"], name: "index_billing_line_items_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_billing_line_items_on_discarded_by_id"
    t.index ["trip_id"], name: "index_billing_line_items_on_trip_id"
  end

  create_table "billing_statements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.date "due_on"
    t.date "ends_on", null: false
    t.integer "grand_total", default: 0, null: false
    t.date "issued_on"
    t.date "month", null: false
    t.string "number", null: false
    t.date "starts_on", null: false
    t.integer "status", default: 0, null: false
    t.integer "total_amount", default: 0, null: false
    t.integer "total_tva", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_billing_statements_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_billing_statements_on_discarded_by_id"
    t.index ["month"], name: "index_billing_statements_on_month", unique: true
    t.index ["number"], name: "index_billing_statements_on_number", unique: true
    t.index ["status"], name: "index_billing_statements_on_status"
  end

  create_table "delivery_notes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "delivered_on"
    t.integer "diesel_quantity", default: 0, null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.integer "gasoline_quantity", default: 0, null: false
    t.integer "missing_quantity", default: 0, null: false
    t.string "number", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_delivery_notes_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_delivery_notes_on_discarded_by_id"
    t.index ["number"], name: "index_delivery_notes_on_number", unique: true
    t.index ["trip_id"], name: "index_delivery_notes_on_trip_id", unique: true
  end

  create_table "documents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.integer "doc_type", default: 0, null: false
    t.bigint "documentable_id", null: false
    t.string "documentable_type", null: false
    t.date "expires_on"
    t.date "issued_on"
    t.string "number", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id"
    t.index ["discarded_at"], name: "index_documents_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_documents_on_discarded_by_id"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
    t.index ["expires_on"], name: "index_documents_on_expires_on"
    t.index ["number"], name: "index_documents_on_number", unique: true
    t.index ["uploaded_by_id"], name: "index_documents_on_uploaded_by_id"
  end

  create_table "maintenance_parts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.bigint "maintenance_id", null: false
    t.string "name", null: false
    t.integer "price", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_maintenance_parts_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_maintenance_parts_on_discarded_by_id"
    t.index ["maintenance_id"], name: "index_maintenance_parts_on_maintenance_id"
  end

  create_table "maintenances", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "actual_duration", precision: 8, scale: 2
    t.integer "cost"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.decimal "estimated_duration", precision: 8, scale: 2
    t.integer "kind", default: 0, null: false
    t.integer "odometer_km"
    t.bigint "performed_by_id"
    t.date "performed_on", null: false
    t.integer "state", default: 0, null: false
    t.bigint "truck_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_maintenances_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_maintenances_on_discarded_by_id"
    t.index ["performed_by_id"], name: "index_maintenances_on_performed_by_id"
    t.index ["performed_on"], name: "index_maintenances_on_performed_on"
    t.index ["truck_id"], name: "index_maintenances_on_truck_id"
  end

  create_table "oauth_access_grants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.bigint "resource_owner_id", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "created_at", null: false
    t.integer "expires_in"
    t.string "previous_refresh_token", default: "", null: false
    t.string "refresh_token"
    t.bigint "resource_owner_id"
    t.datetime "revoked_at"
    t.string "scopes"
    t.string "token", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "calls_count", default: 0, null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.bigint "owner_id"
    t.string "owner_type"
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.string "secret", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_oauth_applications_on_created_by_id"
    t.index ["discarded_at"], name: "index_oauth_applications_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_oauth_applications_on_discarded_by_id"
    t.index ["owner_type", "owner_id"], name: "index_oauth_applications_on_owner_type_and_owner_id", unique: true
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "routes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destination", null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.string "origin", null: false
    t.decimal "rate", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_routes_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_routes_on_discarded_by_id"
    t.index ["origin", "destination"], name: "index_routes_on_origin_and_destination", unique: true
  end

  create_table "tanks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.string "make"
    t.string "model"
    t.string "plate_number", null: false
    t.integer "status", default: 0, null: false
    t.bigint "truck_id", null: false
    t.datetime "updated_at", null: false
    t.string "vin"
    t.integer "year"
    t.index ["discarded_at"], name: "index_tanks_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_tanks_on_discarded_by_id"
    t.index ["plate_number"], name: "index_tanks_on_plate_number", unique: true
    t.index ["truck_id"], name: "index_tanks_on_truck_id", unique: true
    t.index ["vin"], name: "index_tanks_on_vin", unique: true
  end

  create_table "trips", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "actual_end_at"
    t.datetime "actual_start_at"
    t.text "cargo_description"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.decimal "distance_km", precision: 10, scale: 2
    t.bigint "driver_id"
    t.bigint "route_id", null: false
    t.datetime "scheduled_end_at"
    t.datetime "scheduled_start_at"
    t.integer "status", default: 0, null: false
    t.bigint "tank_id", null: false
    t.bigint "truck_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_trips_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_trips_on_discarded_by_id"
    t.index ["driver_id"], name: "index_trips_on_driver_id"
    t.index ["route_id"], name: "index_trips_on_route_id"
    t.index ["status"], name: "index_trips_on_status"
    t.index ["tank_id"], name: "index_trips_on_tank_id"
    t.index ["truck_id"], name: "index_trips_on_truck_id"
  end

  create_table "trucks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.string "make"
    t.string "model"
    t.string "plate_number", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "vin"
    t.integer "year"
    t.index ["created_by_id"], name: "index_trucks_on_created_by_id"
    t.index ["discarded_at"], name: "index_trucks_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_trucks_on_discarded_by_id"
    t.index ["plate_number"], name: "index_trucks_on_plate_number", unique: true
    t.index ["vin"], name: "index_trucks_on_vin", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "discarded_at"
    t.bigint "discarded_by_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["discarded_by_id"], name: "index_users_on_discarded_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "users_roles", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "billing_line_items", "billing_statements"
  add_foreign_key "billing_line_items", "trips"
  add_foreign_key "billing_line_items", "users", column: "discarded_by_id"
  add_foreign_key "billing_statements", "users", column: "discarded_by_id"
  add_foreign_key "delivery_notes", "trips"
  add_foreign_key "delivery_notes", "users", column: "discarded_by_id"
  add_foreign_key "documents", "users", column: "discarded_by_id"
  add_foreign_key "documents", "users", column: "uploaded_by_id"
  add_foreign_key "maintenance_parts", "maintenances"
  add_foreign_key "maintenance_parts", "users", column: "discarded_by_id"
  add_foreign_key "maintenances", "trucks"
  add_foreign_key "maintenances", "users", column: "discarded_by_id"
  add_foreign_key "maintenances", "users", column: "performed_by_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "oauth_applications", "users", column: "created_by_id"
  add_foreign_key "oauth_applications", "users", column: "discarded_by_id"
  add_foreign_key "routes", "users", column: "discarded_by_id"
  add_foreign_key "tanks", "trucks"
  add_foreign_key "tanks", "users", column: "discarded_by_id"
  add_foreign_key "trips", "routes"
  add_foreign_key "trips", "tanks"
  add_foreign_key "trips", "trucks"
  add_foreign_key "trips", "users", column: "discarded_by_id"
  add_foreign_key "trips", "users", column: "driver_id"
  add_foreign_key "trucks", "users", column: "created_by_id"
  add_foreign_key "trucks", "users", column: "discarded_by_id"
  add_foreign_key "users", "users", column: "discarded_by_id"
end
