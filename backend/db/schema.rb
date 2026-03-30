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

ActiveRecord::Schema[8.0].define(version: 2026_02_18_155507) do
  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.string "location"
    t.string "external_id"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_competitions_on_external_id"
  end

  create_table "gymnasts", force: :cascade do |t|
    t.string "name"
    t.string "external_id"
    t.string "team"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_gymnasts_on_external_id"
  end

  create_table "scores", force: :cascade do |t|
    t.integer "gymnast_id", null: false
    t.integer "competition_id", null: false
    t.integer "level"
    t.string "session"
    t.string "division"
    t.decimal "vault"
    t.integer "vault_rank"
    t.decimal "bars"
    t.integer "bars_rank"
    t.decimal "beam"
    t.integer "beam_rank"
    t.decimal "floor"
    t.integer "floor_rank"
    t.decimal "all_around"
    t.integer "all_around_rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_scores_on_competition_id"
    t.index ["gymnast_id"], name: "index_scores_on_gymnast_id"
  end

  add_foreign_key "scores", "competitions"
  add_foreign_key "scores", "gymnasts"
end
