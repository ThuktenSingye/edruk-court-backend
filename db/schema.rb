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

ActiveRecord::Schema[8.0].define(version: 2025_03_24_174409) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.bigint "location_id"
    t.index ["domain"], name: "index_courts_on_domain", unique: true
    t.index ["location_id"], name: "index_courts_on_location_id"
    t.index ["parent_court_id"], name: "index_courts_on_parent_court_id"
    t.index ["subdomain"], name: "index_courts_on_subdomain", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "location_type"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
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

  add_foreign_key "addresses", "profiles"
  add_foreign_key "case_subtypes", "case_types"
  add_foreign_key "courts", "courts", column: "parent_court_id"
  add_foreign_key "courts", "locations"
  add_foreign_key "profiles", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "courts"
end
