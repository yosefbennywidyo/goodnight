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

ActiveRecord::Schema[8.1].define(version: 2025_09_19_192520) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "followed_id"
    t.bigint "follower_id"
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_followed", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "sleeps", force: :cascade do |t|
    t.datetime "clock_in"
    t.datetime "clock_out"
    t.datetime "created_at", null: false
    t.integer "duration"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["clock_in"], name: "index_sleeps_on_clock_in"
    t.index ["clock_out"], name: "index_sleeps_on_clock_out"
    t.index ["created_at"], name: "index_sleeps_on_created_at"
    t.index ["duration"], name: "index_sleeps_on_duration"
    t.index ["duration"], name: "index_sleeps_on_duration_partial", order: :desc, where: "(clock_out IS NOT NULL)"
    t.index ["user_id", "clock_in", "duration"], name: "index_sleeps_on_user_id_clock_in_duration"
    t.index ["user_id", "created_at", "duration"], name: "index_sleeps_on_user_id_created_at_duration"
    t.index ["user_id", "created_at"], name: "index_sleeps_on_user_id_created_at"
    t.index ["user_id"], name: "index_sleeps_on_user_id"
    t.index ["user_id"], name: "index_sleeps_on_user_id_clock_out_null", unique: true, where: "(clock_out IS NULL)"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_users_on_lower_name_unique", unique: true
  end

  add_foreign_key "sleeps", "users"
end
