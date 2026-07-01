module Items
  class UpdateItem
    def initialize(item:, user:, item_params:, branch_id:)
      @item = item
      @user = user
      @item_params = item_params
      @branch_id = branch_id
    end

    def call
      update_item!
      update_branch_item! if branch_item_params_present?
      @item
    end

    private

    def update_item!
      attrs = @item_params.slice(:name, :measure, :cost, :category_id)
      attrs[:active] = @item_params[:active] if @item_params.key?(:active) && @branch_id.blank?
      @item.update!(attrs.merge(updated_by: @user))
    end

    def update_branch_item!
      branch = @user.store.branches.find(@branch_id)
      branch_item = @item.branch_items.find_or_initialize_by(branch: branch)
      branch_item.current_quantity = @item_params[:current_quantity] if @item_params.key?(:current_quantity)
      branch_item.minimum_quantity = @item_params[:minimum_quantity] if @item_params.key?(:minimum_quantity)
      branch_item.active = @item_params[:active] if @item_params.key?(:active)
      branch_item.save!
    end

    def branch_item_params_present?
      @branch_id.present? && (
        @item_params.key?(:current_quantity) ||
        @item_params.key?(:minimum_quantity) ||
        @item_params.key?(:active)
      )
    end
  end
end
