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

ActiveRecord::Schema.define(version: 2021_04_13_092821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.datetime "create_time", null: false
    t.integer "user_id", null: false
    t.string "title", null: false
    t.string "key", null: false
    t.integer "type_channel", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "guilds", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "anagramme", default: "", null: false
    t.string "description", default: "", null: false
    t.integer "points", default: 0, null: false
    t.integer "id_stats", default: -1, null: false
    t.integer "maxmember", default: 5, null: false
    t.integer "nbmember", default: 0, null: false
    t.integer "id_admin", null: false
    t.integer "officers", default: [], array: true
    t.integer "banned", default: [], array: true
    t.boolean "deleted", default: false, null: false
    t.datetime "creation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "war_id"
    t.index ["war_id"], name: "index_guilds_on_war_id"
  end

  create_table "histories", force: :cascade do |t|
    t.integer "tournament_id", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "statut"
    t.bigint "host_id"
    t.bigint "opponent_id"
    t.integer "host_height"
    t.integer "oppo_height"
    t.integer "ball_x"
    t.integer "ball_y"
    t.integer "ball_x_dir"
    t.integer "ball_y_dir"
    t.integer "host_score"
    t.integer "opponent_score"
    t.bigint "war_id"
    t.index ["host_id"], name: "index_histories_on_host_id"
    t.index ["opponent_id"], name: "index_histories_on_opponent_id"
    t.index ["war_id"], name: "index_histories_on_war_id"
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "create_time", null: false
    t.integer "user_id", null: false
    t.integer "message_type", null: false
    t.string "message", null: false
    t.integer "target_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sanctions", force: :cascade do |t|
    t.datetime "create_time", null: false
    t.integer "end_time", null: false
    t.integer "user_id", null: false
    t.integer "sanction_type", null: false
    t.integer "target_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stats", force: :cascade do |t|
    t.integer "victory", default: 0, null: false
    t.integer "defeat", default: 0, null: false
    t.integer "tournament", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "maxpoints"
    t.float "speed"
    t.string "tournament_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "email", null: false
    t.string "image", default: "", null: false
    t.boolean "available", default: false, null: false
    t.integer "role", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.string "uid", default: "", null: false
    t.string "provider", default: "", null: false
    t.string "encrypted_password", default: "", null: false
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
    t.string "name"
    t.string "picture_url"
    t.bigint "guild_id"
    t.bigint "stat_id"
    t.string "status"
    t.integer "elo", default: 1000
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guild_id"], name: "index_users_on_guild_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["stat_id"], name: "index_users_on_stat_id"
  end

  create_table "wars", force: :cascade do |t|
    t.integer "guild_id1", null: false
    t.integer "team1", default: [], array: true
    t.integer "points_guild1", default: 0, null: false
    t.integer "guild_id2", null: false
    t.integer "team2", default: [], array: true
    t.integer "points_guild2", default: 0, null: false
    t.datetime "start"
    t.datetime "end"
    t.integer "points", null: false
    t.integer "players", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tournament_id", null: false
    t.index ["tournament_id"], name: "index_wars_on_tournament_id"
  end

  add_foreign_key "guilds", "wars"
  add_foreign_key "histories", "wars"
  add_foreign_key "users", "guilds"
  add_foreign_key "users", "stats"
  add_foreign_key "wars", "tournaments"
end
