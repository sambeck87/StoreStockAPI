class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :measure, null: false
      t.decimal :cost, precision: 12, scale: 2
      t.references :store, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :updated_by, foreign_key: { to_table: :users }
      t.references :created_by, foreign_key: { to_table: :users }
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :items, [:store_id, :name], unique: true
  end
end
