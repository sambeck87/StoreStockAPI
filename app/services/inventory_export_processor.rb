require "csv"

class InventoryExportProcessor
  def initialize(job)
    @job = job
    @export = InventoryExport.find(job.args)
  end

  def call
    return unless @export.status == "pending"

    @export.update!(status: "processing")

    items = Items::InventoryQuery.new(
      current_user: @export.user,
      params: @export.filters.symbolize_keys
    ).call

    generate_csv(items)

    InventoryQueue.complete(@job.id)
    @export.update!(status: "completed")
  rescue => e
    InventoryQueue.fail(@job.id, e.message)
    @export.update!(status: "failed", error_message: e.message)
  end

  private

  def generate_csv(items)
    FileUtils.mkdir_p(File.dirname(@export.file_path))

    CSV.open(@export.file_path, "w") do |csv|
      csv << headers
      items.each do |item|
        csv << row(item)
      end
    end
  end

  def headers
    [
      "ID",
      "Nombre",
      "Medida",
      "Costo",
      "Categoría",
      "Sucursal",
      "Cantidad actual",
      "Cantidad mínima",
      "Estado",
      "Activo"
    ]
  end

  def row(item)
    quantity = item.respond_to?(:inventory_quantity) ? item.inventory_quantity : nil
    minimum  = item.respond_to?(:inventory_minimum) ? item.inventory_minimum : nil
    active   = item.respond_to?(:inventory_active) ? item.inventory_active : item.active

    [
      item.id,
      item.name,
      item.measure,
      item.cost.to_f,
      item.category&.name,
      item.respond_to?(:inventory_branch_name) ? item.inventory_branch_name : nil,
      quantity,
      minimum,
      compute_quantity_status(quantity, minimum),
      active
    ]
  end

  def compute_quantity_status(quantity, minimum)
    return "empty" if quantity.nil? || quantity <= 0
    return "low" if minimum.present? && quantity < minimum

    "complete"
  end
end
