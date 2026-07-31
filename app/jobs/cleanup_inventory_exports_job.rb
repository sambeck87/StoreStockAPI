class CleanupInventoryExportsJob < ApplicationJob
  queue_as :default

  def perform
    InventoryExport
      .where("expires_at < ?", Time.current)
      .find_each do |export|
      export.file.purge if export.file.attached?

      export.destroy!
    end
  end
end
