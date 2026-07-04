namespace :worker do
  desc "Process inventory export jobs from the queue"
  task process: :environment do
    Rails.logger.info "[Worker] Started processing inventory exports"

    trap("TERM") { puts "[Worker] SIGTERM received, shutting down..."; exit }
    trap("INT")  { puts "[Worker] SIGINT received, shutting down..."; exit }

    loop do
      begin
        job = InventoryQueue.poll("inventory_export")

        if job
          Rails.logger.info "[Worker] Processing job ##{job.id}"
          InventoryExportProcessor.new(job).call
          Rails.logger.info "[Worker] Job ##{job.id} completed"
        else
          sleep 2
        end
      rescue => e
        Rails.logger.error "[Worker] Error: #{e.message}"
        sleep 5
      end
    end
  end
end
