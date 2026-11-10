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

ActiveRecord::Schema[8.1].define(version: 2026_11_10_090100) do
  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_areas_on_name", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "industry", null: false
    t.integer "starting_salary"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "work_location"
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "company_areas", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "area_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_company_areas_on_area_id"
    t.index ["company_id", "area_id"], name: "index_company_areas_on_company_id_and_area_id", unique: true
    t.index ["company_id"], name: "index_company_areas_on_company_id"
  end

  create_table "es_drafts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "company_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name", null: false
    t.index ["company_id"], name: "index_es_drafts_on_company_id"
    t.index ["user_id"], name: "index_es_drafts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "company_areas", "areas"
  add_foreign_key "company_areas", "companies"
  add_foreign_key "es_drafts", "companies"
  add_foreign_key "es_drafts", "users"
end
