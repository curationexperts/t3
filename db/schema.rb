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

ActiveRecord::Schema[7.0].define(version: 20_230_417_191_638) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'blueprints', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'bookmarks', id: :serial, force: :cascade do |t|
    t.integer 'user_id', null: false
    t.string 'user_type'
    t.string 'document_id'
    t.string 'document_type'
    t.binary 'title'
    t.datetime 'created_at', precision: nil, null: false
    t.datetime 'updated_at', precision: nil, null: false
    t.index ['document_id'], name: 'index_bookmarks_on_document_id'
    t.index ['user_id'], name: 'index_bookmarks_on_user_id'
  end

  create_table 'fields', force: :cascade do |t|
    t.string 'name'
    t.bigint 'blueprint_id', null: false
    t.boolean 'required'
    t.boolean 'multiple'
    t.integer 'data_type'
    t.integer 'order'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['blueprint_id'], name: 'index_fields_on_blueprint_id'
  end

  create_table 'searches', id: :serial, force: :cascade do |t|
    t.binary 'query_params'
    t.integer 'user_id'
    t.string 'user_type'
    t.datetime 'created_at', precision: nil, null: false
    t.datetime 'updated_at', precision: nil, null: false
    t.index ['user_id'], name: 'index_searches_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'guest', default: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  create_table 'works', force: :cascade do |t|
    t.json 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'blueprint_id', null: false
    t.index ['blueprint_id'], name: 'index_works_on_blueprint_id'
  end

  add_foreign_key 'fields', 'blueprints'
  add_foreign_key 'works', 'blueprints'
end
