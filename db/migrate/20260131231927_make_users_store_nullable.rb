class MakeUsersStoreNullable < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :users, :stores

    change_column_null :users, :store_id, true

    add_foreign_key :users, :stores, on_delete: :nullify
  end
end
