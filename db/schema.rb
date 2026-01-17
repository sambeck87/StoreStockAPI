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

ActiveRecord::Schema[8.1].define(version: 2025_12_13_180759) do
  create_table "branch_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.integer "current_quantity"
    t.bigint "item_id", null: false
    t.integer "minimum_quantity"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["branch_id"], name: "index_branch_items_on_branch_id"
    t.index ["item_id"], name: "index_branch_items_on_item_id"
    t.index ["updated_by_id"], name: "index_branch_items_on_updated_by_id"
  end

  create_table "branch_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["branch_id"], name: "index_branch_users_on_branch_id"
    t.index ["role_id"], name: "index_branch_users_on_role_id"
    t.index ["user_id"], name: "index_branch_users_on_user_id"
  end

  create_table "branches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_main"
    t.bigint "manager_id"
    t.string "name", null: false
    t.string "phone"
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_branches_on_manager_id"
    t.index ["store_id", "is_main"], name: "index_branches_on_store_id_and_is_main", unique: true
    t.index ["store_id", "name"], name: "index_branches_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_branches_on_store_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.string "name", null: false
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["created_by_id"], name: "index_categories_on_created_by_id"
    t.index ["store_id", "name"], name: "index_categories_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_categories_on_store_id"
    t.index ["updated_by_id"], name: "index_categories_on_updated_by_id"
  end

  create_table "items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "category_id", null: false
    t.decimal "cost", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.string "measure", null: false
    t.string "name", null: false
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["created_by_id"], name: "index_items_on_created_by_id"
    t.index ["store_id", "name"], name: "index_items_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_items_on_store_id"
    t.index ["updated_by_id"], name: "index_items_on_updated_by_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.json "permissions"
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "name"], name: "index_roles_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_roles_on_store_id"
  end

  create_table "stores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_stores_on_user_id", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name"
    t.string "password_digest", null: false
    t.bigint "store_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["store_id"], name: "index_users_on_store_id"
  end

  add_foreign_key "branch_items", "branches"
  add_foreign_key "branch_items", "items"
  add_foreign_key "branch_items", "users", column: "updated_by_id"
  add_foreign_key "branch_users", "branches"
  add_foreign_key "branch_users", "roles"
  add_foreign_key "branch_users", "users"
  add_foreign_key "branches", "stores"
  add_foreign_key "branches", "users", column: "manager_id"
  add_foreign_key "categories", "stores"
  add_foreign_key "categories", "users", column: "created_by_id"
  add_foreign_key "categories", "users", column: "updated_by_id"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "stores"
  add_foreign_key "items", "users", column: "created_by_id"
  add_foreign_key "items", "users", column: "updated_by_id"
  add_foreign_key "roles", "stores"
  add_foreign_key "stores", "users"
  add_foreign_key "users", "stores"
end
