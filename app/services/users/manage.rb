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
    end
  end

  private

  def update_status
    @user.update!(active: @params[:active])
  end

  def assign_branch_and_role
    branch = Branch.find(@params[:branch_id])
    role   = Role.find(@params[:role_id])

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
