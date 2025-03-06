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

ActiveRecord::Schema[8.0].define(version: 2025_03_05_201849) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "courts", force: :cascade do |t|
    t.string "name"
    t.integer "type"
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

  add_foreign_key "courts", "courts", column: "parent_court_id"
end
