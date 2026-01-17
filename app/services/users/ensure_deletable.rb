class Users::EnsureDeletable
  def initialize(user:)
    @user = user
  end

  def call
    if Branch.where(manager_id: @user.id).exists?
      raise BusinessRuleError.new(
        I18n.t("errors.user.has_managed_branches")
      )
    end
  end
end