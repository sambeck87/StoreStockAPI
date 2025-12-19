module Stores
  class CreateStore
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      Store.create!(
        @params.merge(user: @user)
      )
    end
  end
end