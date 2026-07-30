class AddStoreToUser < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :store, foreign_key: true, null: true
  end
end
