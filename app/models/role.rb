class Role < ApplicationRecord
  belongs_to :store

  has_many :users
  has_many :branch_users

  validates :name, presence: true

  ALL_PERMISSIONS = {user: [:index, :show, :create, :update, :delete],
                      store: [:index, :show, :create, :update, :delete],
                      branch: [:index, :show, :create, :update, :delete],
                      category: [:index, :show, :create, :update, :delete],
                      item: [:index, :show, :create, :update, :delete],
                      role: [:index, :show, :create, :update, :delete],
                      permission: [:index, :show, :create, :update, :delete]
                    }

  def allows?(resource, action)
    permissions
      .fetch(resource.to_s, [])
      .include?(action.to_s)
  end
end
