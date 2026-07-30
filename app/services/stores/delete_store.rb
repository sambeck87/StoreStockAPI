module Stores
  class DeleteStore
    def initialize(actor:, store:)
      @actor = actor
      @store = store
    end

    def call
      ActiveRecord::Base.transaction do
        delete_items
        delete_categories
        delete_branch_users
        delete_branches
        delete_roles
        delete_global_permissions
        delete_users
        delete_store
      end
    end

    private

    attr_reader :actor, :store

    def delete_users
      User
        .joins(branch_users: :branch)
        .where(branches: { store_id: store.id })
        .where.not(users: { id: actor.id })
        .distinct
        .destroy_all
    end

    def delete_branches
      store.branches.find_each do |branch|
        branch.destroying_store = true
        branch.destroy!
      end
    end

    def delete_categories
      store.categories.destroy_all
    end

    def delete_items
      store.items.destroy_all
    end

    def delete_roles
      store.roles.destroy_all
    end

    def delete_global_permissions
      store.global_permissions.destroy_all
    end

    def delete_branch_users
      BranchUser
        .joins(:branch)
        .where(branches: { store_id: store.id })
        .where.not(user_id: actor.id)
        .delete_all
    end

    def delete_store
      store.destroy!
    end
  end
end
