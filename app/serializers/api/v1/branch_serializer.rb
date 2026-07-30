class Api::V1::BranchSerializer < BaseSerializer
  def initialize(branch)
    @branch = branch
  end

  def compact
    {
      id: @branch.id,
      name: @branch.name,
      phone: @branch.phone,
      manager_name: @branch.manager&.full_name
    }
  end

  def full
    {
      id: @branch.id,
      name: @branch.name,
      phone: @branch.phone,
      main_branch: @branch.is_main,
      manager_name: @branch.manager&.full_name,
      manager_email: @branch.manager&.email
    }
  end
end
