class CreateBranchItems < ActiveRecord::Migration[8.1]
  def change
    create_table :branch_items do |t|
      t.references :branch, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.references :updated_by, foreign_key: { to_table: :users }
      t.integer :current_quantity
      t.integer :minimum_quantity

      t.timestamps
    end
  end
end
