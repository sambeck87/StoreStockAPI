class Api::V1::StoreSerializer < BaseSerializer
  def initialize(store)
    @store = store
  end

  def compact
    {
      id: @store.id,
      name: @store.name,
      manager_name: @store.user.full_name
    }
  end

  def full
    {
      id: @store.id,
      name: @store.name,
      manager_name: @store.user.full_name,
      manager_email: @store.user.email
    }
  end
end