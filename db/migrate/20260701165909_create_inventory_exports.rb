class CreateInventoryExports < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_exports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.json :filters
      t.string :error_message

      t.timestamps
    end
  end
end
