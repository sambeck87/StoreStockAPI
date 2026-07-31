class InventoryExport < ApplicationRecord
  belongs_to :user
  belongs_to :store

  has_one_attached :file

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

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def downloadable?
    completed? && !expired?
  end
end
