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

ActiveRecord::Schema[7.0].define(version: 2023_04_13_171328) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blueprints", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields", force: :cascade do |t|
    t.string "name"
    t.bigint "blueprint_id", null: false
    t.boolean "required"
    t.boolean "multiple"
    t.integer "data_type"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_id"], name: "index_fields_on_blueprint_id"
  end

  create_table "works", force: :cascade do |t|
    t.json "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "blueprint_id", null: false
    t.index ["blueprint_id"], name: "index_works_on_blueprint_id"
  end

  add_foreign_key "fields", "blueprints"
  add_foreign_key "works", "blueprints"
end
