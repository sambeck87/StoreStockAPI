class Categories::FindAccessible
  def initialize(current_user:, params:)
    @current_user = current_user
    @params       = params
  end

  def call
    base_scope.find(@params[:id])
  end

  private

  def base_scope
    Category.where(store_id: @current_user.store_id)
             .includes(:updated_by, :created_by)
  end
end
