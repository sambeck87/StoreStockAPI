module Branches
  class CreateMainBranch
    def initialize(store:)
      @store = store
    end

    def call
      Branch.create!(
        store: @store,
        name: "Main",
        is_main: true
      )
    end
  end
end
