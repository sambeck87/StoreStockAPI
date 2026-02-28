module Items
  class CreateItem
    def initialize(user:, params:, current_branch: nil, current_category: nil)
      @user = user
      @params = params
      @current_branch = current_branch
      @current_category = current_category
    end

    def call
      category = find_category!
      branch = resolve_branch

      item = find_or_create_item!(category)

      raise DependencyViolationError.new(
        I18n.t("errors.item.already_exists_in_branch"),
        details: { branch_id: branch.id, item_id: item.id }
      ) if BranchItem.exists?(branch_id: branch.id, item_id: item.id)

      branch_item = BranchItem.new(
        branch: branch,
        item: item,
        current_quantity: @params[:current_quantity],
        minimum_quantity: @params[:minimum_quantity]
      )

      ItemTransaction.new(item: item, branch_item: branch_item)
    end

    private

    def item_params
      @params.permit(:name, :measure, :cost, :active, :category_id)
    end

    def find_category!
      return @current_category if @current_category.present?
      return @user.store.categories.find(@params[:category_id]) if @params[:category_id].present?

      raise NotFoundError.new
    end

    def find_or_create_item!(category)
      normalized_name = @params[:name].strip.titleize

      item = Item.find_by(store_id: @user.store.id, name: normalized_name)

      return item if item.present?

      Item.new(
        name: normalized_name,
        measure: @params[:measure],
        cost: @params[:cost],
        active: @params[:active] || true,
        category: category,
        created_by: @user,
        store: @user.store
      )
    end

    def resolve_branch
      return @current_branch if @current_branch.present?
      return @user.store.branches.find(@params[:branch_id]) if @params[:branch_id].present? && @user.global_permission.present?

      @user.branches.first!
    end
  end

  class ItemTransaction
    attr_reader :item, :branch_item

    def initialize(item:, branch_item:)
      @item = item
      @branch_item = branch_item
    end

    def save!
      Item.transaction do
        @item.save! if @item.new_record?
        @branch_item.save!
      end

      self
    end
  end
end
