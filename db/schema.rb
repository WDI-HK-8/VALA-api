# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150908084406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string   "address"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "type"
  end

  create_table "requests", force: :cascade do |t|
    t.string   "status"
    t.string   "auth_code_pick_up"
    t.datetime "car_pick_up_time"
    t.string   "bay_number"
    t.datetime "request_drop_off_time"
    t.string   "auth_code_drop_off"
    t.integer  "rating_pick_up"
    t.integer  "rating_drop_off"
    t.decimal  "tip"
    t.decimal  "total"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.integer  "valet_pick_up_id"
    t.integer  "valet_drop_off_id"
    t.integer  "source_location_id"
    t.integer  "parking_location_id"
    t.integer  "destination_location_id"
  end

  add_index "requests", ["destination_location_id"], name: "index_requests_on_destination_location_id", using: :btree
  add_index "requests", ["parking_location_id"], name: "index_requests_on_parking_location_id", using: :btree
  add_index "requests", ["source_location_id"], name: "index_requests_on_source_location_id", using: :btree
  add_index "requests", ["user_id"], name: "index_requests_on_user_id", using: :btree
  add_index "requests", ["valet_drop_off_id"], name: "index_requests_on_valet_drop_off_id", using: :btree
  add_index "requests", ["valet_pick_up_id"], name: "index_requests_on_valet_pick_up_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "profile_picture"
    t.string   "email"
    t.string   "phone_number"
    t.string   "car_picture"
    t.string   "car_color"
    t.string   "car_make"
    t.string   "car_license_plate"
    t.boolean  "is_manual"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

  create_table "valet_logs", force: :cascade do |t|
    t.string   "status"
    t.integer  "valet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "valet_logs", ["valet_id"], name: "index_valet_logs_on_valet_id", using: :btree

  create_table "valets", force: :cascade do |t|
    t.string   "provider",                   default: "email",       null: false
    t.string   "uid",                        default: "",            null: false
    t.string   "encrypted_password",         default: "",            null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "profile_picture"
    t.string   "email"
    t.string   "phone_number"
    t.string   "HKID"
    t.datetime "driver_license_expiry_date"
    t.integer  "years_of_driving"
    t.boolean  "manual"
    t.string   "status",                     default: "unavailable"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "valets", ["email"], name: "index_valets_on_email", using: :btree
  add_index "valets", ["reset_password_token"], name: "index_valets_on_reset_password_token", unique: true, using: :btree
  add_index "valets", ["uid", "provider"], name: "index_valets_on_uid_and_provider", unique: true, using: :btree

  add_foreign_key "requests", "locations", column: "destination_location_id"
  add_foreign_key "requests", "locations", column: "parking_location_id"
  add_foreign_key "requests", "locations", column: "source_location_id"
  add_foreign_key "requests", "users"
  add_foreign_key "requests", "valets", column: "valet_drop_off_id"
  add_foreign_key "requests", "valets", column: "valet_pick_up_id"
  add_foreign_key "valet_logs", "valets"
end
