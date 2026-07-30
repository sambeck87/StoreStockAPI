module Branches
  class AssignManager
    def initialize(branch:, manager_id:)
      @branch = branch
      @manager_id = manager_id
    end

    def call
      prevent_main_branch_manager_change!

      manager = find_user! if @manager_id.present?

      @branch.manager_id = manager&.id
    end

    private

    def find_user!
      User.find_by!(id: @manager_id, store_id: @branch.store_id)
    end

    def prevent_main_branch_manager_change!
      return unless @branch.is_main

      raise BusinessRuleError.new(
        I18n.t("errors.branch.main_branch_manager_immutable")
      )
    end
  end
end
