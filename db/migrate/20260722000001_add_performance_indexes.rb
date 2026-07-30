class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :branch_items, [ :branch_id, :item_id ], unique: true, name: "index_branch_items_on_branch_and_item"
    add_index :branch_users, [ :user_id, :branch_id ], unique: true, name: "index_branch_users_on_user_and_branch"
    add_index :users, :reset_password_token, name: "index_users_on_reset_password_token"
    add_index :users, :confirmation_token, name: "index_users_on_confirmation_token"
    add_index :users, [ :store_id, :active ], name: "index_users_on_store_id_and_active"
  end
end
