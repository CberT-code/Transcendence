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

ActiveRecord::Schema.define(version: 2021_04_30_061612) do

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
    t.bigint "admin_id"
    t.index ["admin_id"], name: "index_guilds_on_admin_id"
    t.index ["war_id"], name: "index_guilds_on_war_id"
  end

  create_table "histories", force: :cascade do |t|
    t.integer "tournament_id", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "statut", default: 0
    t.bigint "host_id"
    t.bigint "opponent_id"
    t.integer "host_score", default: 0
    t.integer "opponent_score", default: 0
    t.boolean "ranked"
    t.bigint "war_id"
    t.boolean "war_match", default: false
    t.integer "timeout", default: -1
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

  create_table "tournament_users", force: :cascade do |t|
    t.integer "losses", default: 0
    t.integer "wins", default: 0
    t.integer "user_id"
    t.integer "tournament_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "difference", default: 0
    t.integer "elo", default: 1000
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
    t.integer "status", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "email"
    t.string "image"
    t.boolean "available", default: false, null: false
    t.integer "role", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.string "uid", default: ""
    t.string "provider", default: ""
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
    t.bigint "guild_id"
    t.bigint "stat_id"
    t.string "status"
    t.integer "friends", default: [], array: true
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.boolean "locked", default: false
    t.boolean "banned", default: false
    t.index ["guild_id"], name: "index_users_on_guild_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["stat_id"], name: "index_users_on_stat_id"
  end

  create_table "wars", force: :cascade do |t|
    t.integer "guild1_id", null: false
    t.integer "team1", default: [], array: true
    t.integer "points_guild1", default: 0, null: false
    t.integer "guild2_id", null: false
    t.integer "team2", default: [], array: true
    t.integer "points_guild2", default: 0, null: false
    t.datetime "start"
    t.datetime "end"
    t.integer "points", null: false
    t.integer "players", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tournament_id", null: false
    t.integer "timeout", default: 30
    t.boolean "allow_ext", default: true
    t.integer "forfeitedGames1", default: 0
    t.integer "forfeitedGames2", default: 0
    t.boolean "ongoingMatch", default: false
    t.boolean "wartime", default: false
    t.index ["tournament_id"], name: "index_wars_on_tournament_id"
  end

  add_foreign_key "users", "guilds"
  add_foreign_key "users", "stats"
  add_foreign_key "wars", "tournaments"
end
