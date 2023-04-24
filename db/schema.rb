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

ActiveRecord::Schema[7.0].define(version: 2023_04_21_095531) do
  create_table "accounts", force: :cascade do |t|
    t.integer "steamID32"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "match_stat_id"
    t.index ["match_stat_id"], name: "index_accounts_on_match_stat_id"
  end

  create_table "heros", force: :cascade do |t|
    t.integer "hero_id"
    t.string "name_en"
    t.string "name_ru"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "match_stat_id"
    t.index ["match_stat_id"], name: "index_heros_on_match_stat_id"
  end

  create_table "match_stats", force: :cascade do |t|
    t.integer "kills"
    t.integer "deaths"
    t.integer "assists"
    t.integer "last_hits"
    t.integer "denies"
    t.integer "networce"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "match_id"
    t.index ["match_id"], name: "index_match_stats_on_match_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "serial"
    t.integer "score_radiant"
    t.integer "score_dire"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "match_stats"
  add_foreign_key "heros", "match_stats"
  add_foreign_key "match_stats", "matches"
end
