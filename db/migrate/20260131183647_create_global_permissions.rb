class CreateGlobalPermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :global_permissions do |t|
      t.references :store, null: false, foreign_key: true
      t.string :name
      t.json :permissions

      t.timestamps
    end

    add_index :global_permissions, [:store_id, :name], unique: true
  end
end
