class AddRoleAndStoreToUser < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :role, foreign_key: true, null: true
    add_reference :users, :store, foreign_key: true, null: true
  end
end
