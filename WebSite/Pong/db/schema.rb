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

ActiveRecord::Schema.define(version: 2021_03_25_163808) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "type_name", default: "", null: false
    t.string "description", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "guilds", force: :cascade do |t|
    t.citext "name", default: "", null: false
    t.string "description", default: "", null: false
    t.datetime "creation"
    t.integer "id_stats", default: -1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "maxmember"
    t.integer "nbmember"
    t.integer "id_admin"
    t.boolean "in_war", default: false, null: false
  end

  create_table "histories", force: :cascade do |t|
    t.integer "target_type", default: -1, null: false
    t.integer "target_1", default: -1, null: false
    t.integer "target_2", default: -1, null: false
    t.integer "score_target_1", default: 0, null: false
    t.integer "score_target_2", default: 0, null: false
    t.datetime "start"
    t.datetime "end"
    t.integer "id_type", default: -1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "statut"
    t.integer "points", default: 0, null: false
    t.integer "id_war", default: 0, null: false
  end

  create_table "stats", force: :cascade do |t|
    t.integer "victory", default: 0, null: false
    t.integer "defeat", default: 0, null: false
    t.integer "tournament", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tournaments", force: :cascade do |t|
    t.integer "id_type", default: -1, null: false
    t.string "name", default: "", null: false
    t.string "description", default: "", null: false
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "id_guild", default: -1, null: false
    t.integer "id_stats", default: -1, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.citext "nickname"
    t.string "image"
    t.integer "role"
    t.integer "guild_role"
    t.integer "points", default: 0, null: false
    t.boolean "available", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id_guild"], name: "index_users_on_id_guild"
    t.index ["id_stats"], name: "index_users_on_id_stats", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wars", force: :cascade do |t|
    t.integer "id_guild1", default: -1, null: false
    t.integer "team1", default: [], array: true
    t.integer "points_guild1", default: -1, null: false
    t.integer "id_guild2", default: -1, null: false
    t.integer "team2", default: [], array: true
    t.integer "points_guild2", default: -1, null: false
    t.datetime "start"
    t.datetime "end"
    t.integer "points", default: -1, null: false
    t.integer "players", default: -1, null: false
    t.integer "status", default: -1, null: false
  end

end
