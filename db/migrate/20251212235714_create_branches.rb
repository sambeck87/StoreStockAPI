class CreateBranches < ActiveRecord::Migration[8.1]
  def change
    create_table :branches do |t|
      t.string :name, null: false
      t.string :phone
      t.boolean :is_main
      t.references :store, null: false, foreign_key: true
      t.references :manager, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :branches, [:store_id, :name], unique: true
    add_index :branches, [:store_id, :is_main], unique: true
  end
end
