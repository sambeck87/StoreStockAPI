class JobQueue < ApplicationRecord
  self.table_name = "job_queue"
  validates :job_type, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }

  scope :pending, -> { where(status: "pending") }
  scope :by_type, ->(type) { where(job_type: type) }
end
