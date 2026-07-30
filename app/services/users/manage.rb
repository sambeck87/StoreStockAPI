class Users::Manage
  def initialize(actor:, user:, params:)
    @actor = actor
    @user  = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      update_status if @params.key?(:active)
      assign_branch_and_role if branch_or_role?
      assign_global_permission if @params.key?(:global_permission_id)
    end
  end

  private

  def update_status
    @user.update!(active: @params[:active])
  end

  def assign_global_permission
    if @params[:global_permission_id].nil?
      @user.update!(global_permission: nil)
    else
      global_permission = GlobalPermission.find(@params[:global_permission_id])
      @user.update!(global_permission: global_permission)
    end
  end

  def assign_branch_and_role
    branch = Branch.find(@params[:branch_id])
    role   = Role.find(@params[:role_id])
    global_permission = GlobalPermission.find_by(id: @params[:global_permission_id])

    BranchUser.find_or_initialize_by(
      user: @user,
      branch: branch
    ).tap do |bu|
      bu.role = role
      bu.save!
    end
  end

  def branch_or_role?
    @params[:branch_id].present? || @params[:role_id].present?
  end
end
