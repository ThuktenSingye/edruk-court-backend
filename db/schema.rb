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

ActiveRecord::Schema[8.0].define(version: 2025_05_02_130707) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "dzongkhag"
    t.string "gewog"
    t.string "street_address"
    t.integer "address_type"
    t.bigint "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_addresses_on_profile_id"
  end

  create_table "case_documents", force: :cascade do |t|
    t.string "hash_value"
    t.bigint "hearing_id"
    t.boolean "verified_by_judge", default: true
    t.datetime "verified_at"
    t.integer "document_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "case_id"
    t.index ["case_id"], name: "index_case_documents_on_case_id"
    t.index ["hash_value", "hearing_id"], name: "index_case_documents_on_hash_value_and_hearing_id", unique: true
    t.index ["hash_value"], name: "index_case_documents_on_hash_value", unique: true
    t.index ["hearing_id"], name: "index_case_documents_on_hearing_id"
  end

  create_table "case_evidences", force: :cascade do |t|
    t.string "hash_value"
    t.bigint "hearing_id", null: false
    t.boolean "verified_by_judge"
    t.datetime "verified_at"
    t.integer "evidence_status"
    t.string "file_type"
    t.boolean "is_encrypted"
    t.string "iv"
    t.string "auth_tag"
    t.string "encrypted_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_value", "hearing_id"], name: "index_case_evidences_on_hash_value_and_hearing_id", unique: true
    t.index ["hash_value"], name: "index_case_evidences_on_hash_value", unique: true
    t.index ["hearing_id"], name: "index_case_evidences_on_hearing_id"
  end

  create_table "case_participants", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "case_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "cid_no"
    t.jsonb "address_data", default: []
    t.index ["case_id"], name: "index_case_participants_on_case_id"
    t.index ["role_id"], name: "index_case_participants_on_role_id"
    t.index ["user_id"], name: "index_case_participants_on_user_id"
  end

  create_table "case_subtypes", force: :cascade do |t|
    t.string "title"
    t.bigint "case_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_type_id"], name: "index_case_subtypes_on_case_type_id"
    t.index ["title"], name: "index_case_subtypes_on_title", unique: true
  end

  create_table "case_types", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_case_types_on_title", unique: true
  end

  create_table "cases", force: :cascade do |t|
    t.string "case_number"
    t.string "registration_number"
    t.string "judgement_number"
    t.string "title"
    t.text "summary"
    t.integer "case_priority"
    t.boolean "is_appeal", default: false
    t.boolean "is_enforced", default: false
    t.boolean "is_remanded", default: false
    t.boolean "is_reopened", default: false
    t.integer "case_status"
    t.bigint "court_id", null: false
    t.bigint "case_subtype_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "case_type_id"
    t.bigint "bench_id"
    t.index ["bench_id"], name: "index_cases_on_bench_id"
    t.index ["case_number"], name: "index_cases_on_case_number", unique: true
    t.index ["case_status"], name: "index_cases_on_case_status"
    t.index ["case_subtype_id"], name: "index_cases_on_case_subtype_id"
    t.index ["case_type_id"], name: "index_cases_on_case_type_id"
    t.index ["court_id"], name: "index_cases_on_court_id"
    t.index ["is_appeal"], name: "index_cases_on_is_appeal"
    t.index ["is_enforced"], name: "index_cases_on_is_enforced"
    t.index ["is_remanded"], name: "index_cases_on_is_remanded"
    t.index ["is_reopened"], name: "index_cases_on_is_reopened"
    t.index ["judgement_number"], name: "index_cases_on_judgement_number", unique: true
    t.index ["registration_number"], name: "index_cases_on_registration_number", unique: true
  end

  create_table "courts", force: :cascade do |t|
    t.string "name"
    t.integer "court_type"
    t.string "email"
    t.string "contact_no"
    t.string "subdomain"
    t.string "domain"
    t.bigint "parent_court_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_courts_on_domain", unique: true
    t.index ["parent_court_id"], name: "index_courts_on_parent_court_id"
    t.index ["subdomain"], name: "index_courts_on_subdomain", unique: true
  end

  create_table "document_signatures", force: :cascade do |t|
    t.text "signature_data"
    t.datetime "signed_at"
    t.bigint "signer_id", null: false
    t.string "signable_type", null: false
    t.bigint "signable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["signable_type", "signable_id"], name: "index_document_signatures_on_signable"
    t.index ["signer_id"], name: "index_document_signatures_on_signer_id"
  end

  create_table "hearing_notes", force: :cascade do |t|
    t.text "content"
    t.bigint "hearing_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_hearing_notes_on_author_id"
    t.index ["hearing_id"], name: "index_hearing_notes_on_hearing_id"
  end

  create_table "hearing_schedules", force: :cascade do |t|
    t.datetime "scheduled_date"
    t.integer "schedule_status"
    t.text "reschedule_reason"
    t.bigint "hearing_id", null: false
    t.bigint "scheduled_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hearing_id"], name: "index_hearing_schedules_on_hearing_id"
    t.index ["scheduled_by_id"], name: "index_hearing_schedules_on_scheduled_by_id"
  end

  create_table "hearing_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_hearing_types_on_name", unique: true
  end

  create_table "hearings", force: :cascade do |t|
    t.integer "hearing_status"
    t.bigint "case_id", null: false
    t.bigint "hearing_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_hearings_on_case_id"
    t.index ["hearing_type_id"], name: "index_hearings_on_hearing_type_id"
  end

  create_table "jurisdictions", force: :cascade do |t|
    t.string "name"
    t.integer "jurisdiction_type"
    t.integer "parent_id"
    t.bigint "court_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_jurisdictions_on_court_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "hearing_id", null: false
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hearing_id"], name: "index_notes_on_hearing_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "cid_no"
    t.string "phone_number"
    t.string "house_no"
    t.string "thram_no"
    t.integer "age"
    t.integer "gender"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cid_no"], name: "index_profiles_on_cid_no", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.text "public_key"
    t.text "private_key"
    t.bigint "court_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["court_id"], name: "index_users_on_court_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "profiles"
  add_foreign_key "case_documents", "cases"
  add_foreign_key "case_documents", "hearings"
  add_foreign_key "case_evidences", "hearings"
  add_foreign_key "case_participants", "cases"
  add_foreign_key "case_participants", "roles"
  add_foreign_key "case_participants", "users"
  add_foreign_key "case_subtypes", "case_types"
  add_foreign_key "cases", "case_subtypes"
  add_foreign_key "cases", "case_types"
  add_foreign_key "cases", "courts"
  add_foreign_key "cases", "courts", column: "bench_id"
  add_foreign_key "courts", "courts", column: "parent_court_id"
  add_foreign_key "document_signatures", "case_participants", column: "signer_id"
  add_foreign_key "hearing_notes", "hearings"
  add_foreign_key "hearing_notes", "users", column: "author_id"
  add_foreign_key "hearing_schedules", "hearings"
  add_foreign_key "hearing_schedules", "users", column: "scheduled_by_id"
  add_foreign_key "hearings", "cases"
  add_foreign_key "hearings", "hearing_types"
  add_foreign_key "jurisdictions", "courts"
  add_foreign_key "notes", "hearings"
  add_foreign_key "notes", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "users", "courts"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
