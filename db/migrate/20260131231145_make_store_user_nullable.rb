class MakeStoreUserNullable < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :stores, :users

    change_column_null :stores, :user_id, true

    add_foreign_key :stores, :users, on_delete: :nullify
  end
end
