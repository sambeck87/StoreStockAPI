class BranchUsers::FindAccessible
  def initialize(params:)
    @params = params
  end

  def call
    BranchUser.includes(branch: :store).find_by!(
        user_id: @params[:id],
        branch_id: @params[:branch_id]
      )
  end
end
