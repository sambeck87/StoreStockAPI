class AddActiveToBranchItems < ActiveRecord::Migration[7.2]
  def change
    add_column :branch_items, :active, :boolean, default: true, null: false
  end
end
