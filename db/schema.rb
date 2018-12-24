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

ActiveRecord::Schema.define(version: 2018_12_22_084511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ip_addresses", force: :cascade do |t|
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.integer "count_noticed_authors", default: 0, null: false
    t.bigint "users", default: [], null: false, array: true
    t.index ["count_noticed_authors"], name: "index_ip_addresses_on_count_noticed_authors"
    t.index ["ip_address"], name: "index_ip_addresses_on_ip_address", unique: true
    t.index ["users"], name: "index_ip_addresses_on_users", using: :gin
  end

  create_table "posts", force: :cascade do |t|
    t.string "header", null: false
    t.text "content", null: false
    t.inet "author_ip", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.decimal "value", precision: 3, scale: 2, default: "2.5", null: false
    t.bigint "post_id", null: false
    t.index ["post_id"], name: "index_ratings_on_post_id"
  end

  create_table "statistics", force: :cascade do |t|
    t.integer "rating_sum", default: 0
    t.integer "rating_count", default: 0
    t.decimal "rating_avg", precision: 4, scale: 2, default: "0.0"
    t.bigint "post_id", null: false
    t.index ["post_id"], name: "index_statistics_on_post_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "login", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  add_foreign_key "posts", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "ratings", "posts", on_delete: :cascade
  add_foreign_key "statistics", "posts", on_delete: :cascade
end
