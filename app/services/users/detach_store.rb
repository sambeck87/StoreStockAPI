class Users::DetachStore
  def initialize(actor:, user:)
    @actor = actor
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      @user.update!(store: nil)

      @user.branch_users.destroy_all

      @user.global_permission&.destroy
    end

    @user
  end
end
