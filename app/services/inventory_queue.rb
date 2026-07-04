class InventoryQueue
  JobNotFound = Class.new(StandardError)

  def self.enqueue(export_id)
    JobQueue.create!(
      job_type: "inventory_export",
      args: export_id.to_s,
      status: "pending"
    )
  end

  def self.poll(job_type = "inventory_export")
    job = JobQueue.where(job_type: job_type, status: "pending")
                  .order(created_at: :asc)
                  .limit(1)
                  .first

    return nil unless job

    updated = JobQueue.where(id: job.id, status: "pending")
                      .update_all(status: "processing", updated_at: Time.current)

    return nil if updated == 0

    job.reload
  end

  def self.complete(job_id)
    find_job(job_id).update!(status: "completed")
  end

  def self.fail(job_id, error_message)
    find_job(job_id).update!(status: "failed", error_message: error_message)
  end

  def self.pending_count(job_type = nil)
    scope = JobQueue.where(status: "pending")
    scope = scope.where(job_type: job_type) if job_type
    scope.count
  end

  def self.processing_count(job_type = nil)
    scope = JobQueue.where(status: "processing")
    scope = scope.where(job_type: job_type) if job_type
    scope.count
  end

  def self.find_job(job_id)
    JobQueue.find(job_id)
  rescue ActiveRecord::RecordNotFound
    raise JobNotFound, "Job ##{job_id} not found"
  end
end
