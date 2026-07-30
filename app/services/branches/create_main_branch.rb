module Branches
  class CreateMainBranch
    def initialize(store:, manager:)
      @store = store
      @manager = manager
    end

    def call
      Branch.create!(
        store: @store,
        name: "Main",
        manager: @manager,
        is_main: true
      )
    end
  end
end
