class ChangeGlobalPermissionFkOnUsers < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :users, :global_permissions

    add_foreign_key :users,
                    :global_permissions,
                    on_delete: :nullify
  end
end
