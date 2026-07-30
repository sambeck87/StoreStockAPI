class Api::V1::Inventory::ExportsController < ApplicationController
  wrap_parameters false

  def create
    raise AuthorizationError unless policy_for(Item).index?

    items = Items::InventoryQuery.new(
      current_user: current_user,
      params: export_params
    ).call

    if items.empty?
      render json: { error: "Stock vacío, no se puede descargar el reporte" },
             status: :unprocessable_entity
      return
    end

    export = InventoryExport.create!(
      user: current_user,
      store: current_user.store,
      status: "pending",
      filters: export_params
    )

    InventoryExportJob.perform_later(export.id)

    render json: serialize_export(export), status: :created
  end

  def show
    export = InventoryExport.find(params[:id])
    render json: serialize_export(export)
  end

  def download
    export = InventoryExport.find(params[:id])
    if export.completed?
      send_file export.file_path, type: "text/csv",
                filename: "inventario_#{export.id}.csv"
    else
      render json: { error: "Export not ready" }, status: :not_found
    end
  end

  private

  def export_params
    params.permit(:branch_id, :category_id, :active, :quantity_status)
  end

  def serialize_export(export)
    {
      id: export.id,
      status: export.status,
      filters: export.filters || {},
      error_message: export.error_message,
      download_url: export.completed? ?
        download_api_v1_inventory_export_path(export.id) : nil,
      created_at: export.created_at
    }
  end
end
