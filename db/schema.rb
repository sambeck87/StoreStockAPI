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

ActiveRecord::Schema[8.1].define(version: 2026_07_22_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "branch_items", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.integer "current_quantity"
    t.bigint "item_id", null: false
    t.integer "minimum_quantity"
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.index ["branch_id", "item_id"], name: "index_branch_items_on_branch_and_item", unique: true
    t.index ["branch_id"], name: "index_branch_items_on_branch_id"
    t.index ["item_id"], name: "index_branch_items_on_item_id"
    t.index ["updated_by_id"], name: "index_branch_items_on_updated_by_id"
  end

  create_table "branch_users", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["branch_id"], name: "index_branch_users_on_branch_id"
    t.index ["role_id"], name: "index_branch_users_on_role_id"
    t.index ["user_id", "branch_id"], name: "index_branch_users_on_user_and_branch", unique: true
    t.index ["user_id"], name: "index_branch_users_on_user_id"
  end

  create_table "branches", force: :cascade do |t|
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

  create_table "categories", force: :cascade do |t|
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

  create_table "global_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.json "permissions"
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_global_permissions_on_store_id"
  end

  create_table "inventory_exports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_message"
    t.json "filters"
    t.string "status", default: "pending", null: false
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["store_id"], name: "index_inventory_exports_on_store_id"
    t.index ["user_id"], name: "index_inventory_exports_on_user_id"
  end

  create_table "items", force: :cascade do |t|
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

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.json "permissions"
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "name"], name: "index_roles_on_store_id_and_name", unique: true
    t.index ["store_id"], name: "index_roles_on_store_id"
  end

  create_table "stores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_stores_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name"
    t.bigint "global_permission_id"
    t.string "password_digest", null: false
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.bigint "store_id"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["global_permission_id"], name: "index_users_on_global_permission_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["store_id", "active"], name: "index_users_on_store_id_and_active"
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
  add_foreign_key "global_permissions", "stores"
  add_foreign_key "inventory_exports", "stores"
  add_foreign_key "inventory_exports", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "stores"
  add_foreign_key "items", "users", column: "created_by_id"
  add_foreign_key "items", "users", column: "updated_by_id"
  add_foreign_key "roles", "stores"
  add_foreign_key "stores", "users", on_delete: :nullify
  add_foreign_key "users", "global_permissions", on_delete: :nullify
  add_foreign_key "users", "stores", on_delete: :nullify
end
