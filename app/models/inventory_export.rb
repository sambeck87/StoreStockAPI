class InventoryExport < ApplicationRecord
  belongs_to :user
  belongs_to :store

  def file_path
    self.class.file_path_for(id)
  end

  def self.file_path_for(id)
    Rails.root.join("tmp", "exports", "inventory_#{id}.csv").to_s
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def processing?
    status == "processing"
  end

  def pending?
    status == "pending"
  end
end
