class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.references :store, null: false, foreign_key: true
      t.references :updated_by, foreign_key: { to_table: :users }
      t.references :created_by, foreign_key: { to_table: :users }
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :categories, [:store_id, :name], unique: true
  end
end
