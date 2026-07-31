class AddExpiresAtToInventoryExports < ActiveRecord::Migration[8.1]
  def change
    add_column :inventory_exports, :expires_at, :datetime
  end
end
