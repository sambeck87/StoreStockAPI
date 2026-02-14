module Categories
  class CreateCategory
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      Category.new(
        @params.merge(
          created_by: @user,
          store: @user.store,
          active: true)
      )
    end
  end
end