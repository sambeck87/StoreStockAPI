class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.json :permissions
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end

    add_index :roles, [:store_id, :name], unique: true
  end
end
