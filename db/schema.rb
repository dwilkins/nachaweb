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

ActiveRecord::Schema[8.0].define(version: 2025_07_21_120002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "ach_files", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "filename"
    t.integer "status", default: 0, null: false
    t.integer "storage_type", default: 0, null: false
    t.jsonb "parsed_data"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ach_files_on_user_id"
    t.index ["uuid"], name: "index_ach_files_on_uuid", unique: true
  end

  create_table "ach_input_files", force: :cascade do |t|
    t.bigint "ach_file_id", null: false
    t.string "name"
    t.integer "format"
    t.integer "modality"
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ach_file_id"], name: "index_ach_input_files_on_ach_file_id"
  end

  create_table "api_keys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.string "description"
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_keys_on_token", unique: true
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "ach_files", "users"
  add_foreign_key "ach_input_files", "ach_files"
  add_foreign_key "api_keys", "users"
  add_foreign_key "sessions", "users"
end
