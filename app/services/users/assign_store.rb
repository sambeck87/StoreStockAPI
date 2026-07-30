# app/services/users/assign_store.rb
module Users
  class AssignStore
    def initialize(user:, store_id:)
      @user = user
      @store_id = store_id
    end

    def call
      return if @store_id.blank?

      store = Store.find(@store_id)
      @user.store = store
    end
  end
end
